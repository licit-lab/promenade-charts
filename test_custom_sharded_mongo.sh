#!/bin/bash

echo "Iteration $i"
#helm delete artemis kafka-connect-artemis

sleep 20

#(
#  cd cp-kafka-helm-charts/charts/connect-mongodb-sink-ingestion || exit;
#  helm delete connect-mongo1-sink-ingestion connect-mongo2-sink-ingestion;
#  helm install connect-mongo1-sink-ingestion --set route.name="connect-mongo1-sink-ingestion" .;
#  helm install connect-mongo2-sink-ingestion --set route.name="connect-mongo2-sink-ingestion" .;
#)
#(
#  cd config || exit;
#  sleep 60
#  echo -e "Creating MongoDB Sink Ingestion Connector"
#  curl -s -X POST -H 'Content-Type: application/json' --data @mongodb1-sink-ingestion.json  http://connect-mongo1-sink-ingestion.router.default.svc.cluster.local/connectors
#  sleep 10
#  curl -s -X POST -H 'Content-Type: application/json' --data @mongodb2-sink-ingestion.json  http://connect-mongo2-sink-ingestion.router.default.svc.cluster.local/connectors
#)

#sleep 180

#echo "Collecting results"
#ssh -i ~/.ssh/script69 furno@137.121.170.69 'bash -s' < get_results.sh

#sleep 120

(
  cd /c/Users/anton/Desktop/kafka-exercise || exit
  mvn exec:java -Dexec.mainClass="unisannio.dist.kafka.ParallelConsumers" -Dexec.args="0 mongo"
)

sleep 30