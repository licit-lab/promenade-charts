'''
Created on 17 giu 2021

@author: lorenzo
'''

from pymongo import MongoClient
from multiprocessing import Pool
import itertools
import os
import time

#In the following instructions replace <mongodb_address>, <mongodb_port> and <mongodb_database_name> with their actual values.
ADDRESS=<mongodb_address>
PORT=<mongodb_port>
DB=<mongodb_database_name>
AREAS_FILE_PATH="./areanames.txt"


def chunks(l, n):
    """Divide a list of nodes `l` in `n` chunks"""
    l_c = iter(l)
    while 1:
        x = tuple(itertools.islice(l_c, n))
        if not x:
            return
        yield x
        
def end_to_end_analysis_task(args_tuple):
    client = MongoClient("mongodb://"+ ADDRESS + ":" + PORT + "/")
    db = client[DB]
    
    stats = {}
    
    for aggTimestamp in args_tuple[1]:
        stats[aggTimestamp] = {}
        stats[aggTimestamp]["end-to-end"] = []
        stats[aggTimestamp]["end-to-end_mongo"] = []
        stats[aggTimestamp]["processing"] = []
        stats[aggTimestamp]["ingestion"] = []
        stats[aggTimestamp]["updating"] = []
        for area in args_tuple[0]:
            for doc in db[area].find({"aggTimestamp":aggTimestamp}):
                stats[aggTimestamp]["processing"].append(int(doc["procTimestamp"]) - int(doc["ingTimestamp"]))
                stats[aggTimestamp]["end-to-end"].append(int(doc["_insertedTS"].timestamp()*1000 + 3600000) - int(doc["aggTimestamp"]))
                stats[aggTimestamp]["end-to-end_mongo"].append(int(doc["_id"].generation_time.timestamp()*1000) - int(doc["aggTimestamp"]))
                stats[aggTimestamp]["ingestion"].append(int(doc["ingTimestamp"]) - int(doc["aggTimestamp"]))
                stats[aggTimestamp]["updating"].append(int(doc["_insertedTS"].timestamp()*1000 + 3600000) - int(doc["procTimestamp"]))

    client.close()
    return stats

def end_to_end_analysis_parallel(areas, aggTimestamps, processes=None):
    """Parallel betweenness centrality  function"""
    p = Pool(processes=processes)
    node_divisor = len(p._pool)
    node_chunks = list(chunks(aggTimestamps, int(len(aggTimestamps)/node_divisor)))
    num_chunks = len(node_chunks)
    print("Distributing " + str(num_chunks) + " chunks over " + str(node_divisor) + " processes.")
    partial_stats = p.map(end_to_end_analysis_task, zip([areas]*num_chunks, node_chunks))

    # Reduce the partial solutions
    stats = partial_stats[0]
    for stat in partial_stats[1:]:
        for timestamp in stat:
            stats[timestamp] = {}
            stats[timestamp]["end-to-end"] = stat[timestamp]["end-to-end"]
            stats[timestamp]["end-to-end_mongo"] = stat[timestamp]["end-to-end_mongo"]
            stats[timestamp]["processing"] = stat[timestamp]["processing"]
            stats[timestamp]["ingestion"] = stat[timestamp]["ingestion"]
            stats[timestamp]["updating"] = stat[timestamp]["updating"]
    return stats


if __name__ == '__main__':
    
    '''***Reading areas***'''
    areas = set()
    with open(AREAS_FILE_PATH) as f:
        for line in f.readlines():
            areas.add(line.strip() + "-BC")
    
    print(str(len(areas)) + " areas have been read!")
    
    '''*** Connecting to mongo database***'''
    client = MongoClient("mongodb://"+ ADDRESS + ":" + PORT + "/")
    db = client[DB]
    
    aggTimestamps = db[next(iter(areas))].distinct("aggTimestamp")
    
    client.close()
    
    '''*** End-to-end & processing latency analysis***'''
    start_time = time.time()
    res = end_to_end_analysis_parallel(areas, aggTimestamps, processes=8)
    end_time = time.time()

    print("Analysis took " + str(end_time-start_time) + " seconds.")

    with open("stats.csv", "w") as f:
#       f.write("aggTimestamp;e2e_min;e2e_avg;e2e_max;e2e_mongo_min;e2e_mongo_avg;e2e_mongo_max;ing_min;ing_avg;ing_max;proc_min;proc_avg;proc_max;update_min;update_avg;update_max\n")
        f.write("aggTimestamp;e2e_min;e2e_avg;e2e_max;e2e_mongo_min;e2e_mongo_avg;e2e_mongo_max\n")
        for key,value in res.items():
            f.write(str(key) + ";" + str(min(value["end-to-end"])) + ";" + str(sum(value["end-to-end"])/len(value["end-to-end"])) + ";" + str(max(value["end-to-end"])) + ";" + str(min(value["end-to-end_mongo"])) + ";" + str(sum(value["end-to-end_mongo"])/len(value["end-to-end_mongo"])) + ";" + str(max(value["end-to-end_mongo"])) + "\n")




