'''
Created on 17 giu 2021

@author: lorenzo
'''

from pymongo import MongoClient
from multiprocessing import Pool
import itertools
import os
import time
import argparse

#parser = argparse.ArgumentParser(description='This script extracts data from a mongo instance.')
#parser.add_argument('MONGO_ADDRESS', help='specify ip address mongodb is listening on')
#parser.add_argument('MONGO_PORT', help='specify port number mongodb is listening on')
#args = parser.parse_args()

#In the following instructions replace <mongodb_address>, <mongodb_port> and <mongodb_database_name> with their actual values.
#ADDRESS=args.MONGO_ADDRESS
#PORT=args.MONGO_PORT
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
        
def ingestion_analysis_task(args_tuple):
    client = MongoClient("mongodb://"+ ADDRESS + ":" + PORT + "/")
    db = client[DB]
    
    stats = {}

    i=0
    for area in args_tuple:
        for doc in db[area].find():
            stats[i] = {}
            stats[i]["_id_TS"] = int(doc["_id"].generation_time.timestamp()*1000)
            stats[i]["_inserted_TS"] = int(doc["_insertedTS"].timestamp()*1000 + 3600000) 
            stats[i]["aggTimestamp"] = int(doc["aggTimestamp"])
            stats[i]["domainAggTimestamp"] = int(doc["domainAggTimestamp"])
            stats[i]["linkID"] = doc["linkid"]
            
            i = i + 1
    client.close()
    return stats

def ingestion_analysis_parallel(areas, processes=None):
    """Parallel betweenness centrality  function"""
    p = Pool(processes=processes)
    node_divisor = len(p._pool)
    node_chunks = list(chunks(list(areas), int(len(areas)/node_divisor)))
    num_chunks = len(node_chunks)
    print("Distributing " + str(num_chunks) + " chunks over " + str(node_divisor) + " processes.")
    partial_stats = p.map(ingestion_analysis_task, node_chunks)
    
    # Reduce the partial solutions
    stats = partial_stats[0]
    j = len(stats)
    for stat in partial_stats[1:]:
        for i in stat:
            stats[j] = {}
            stats[j]["_id_TS"] = stat[i]["_id_TS"]
            stats[j]["_inserted_TS"] = stat[i]["_inserted_TS"]
            stats[j]["aggTimestamp"] = stat[i]["aggTimestamp"]
            stats[j]["domainAggTimestamp"] = stat[i]["domainAggTimestamp"]
            stats[j]["linkID"] = stat[i]["linkID"]
            j = j + 1
    print("Number of documents (obs.): " + str(j))
    return stats


if __name__ == '__main__':
    
    '''***Reading areas***'''
    areas = set()
    with open(AREAS_FILE_PATH) as f:
        for line in f.readlines():
            areas.add(line.strip() + "-Northbound")
    
    print(str(len(areas)) + " areas have been read!")
    
    '''***Ingestion latency analysis***'''
    start_time = time.time()
    res = ingestion_analysis_parallel(areas, processes=8)
    end_time = time.time()

    print("Analysis took " + str(end_time-start_time) + " seconds.")

    with open("ingtime_" + str(time.time()).replace(".", "-") + ".csv", "w") as f:
        f.write("doc_n;id_ts;ins_ts;agg_ts;domain_agg_ts;link_id\n")
        for key,value in res.items():
            f.write(str(key) + ";" + str(value["_id_TS"])  + ";" + str(value["_inserted_TS"]) + ";" + str(value["aggTimestamp"]) + ";" + str(value["domainAggTimestamp"]) + ";" + str(value["linkID"]) + "\n")




