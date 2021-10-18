#!/bin/bash

echo "Iteration $i"
helm delete artemis kafka-connect-artemis

sleep 20

(
  cd cp-kafka-helm-charts/charts/connect-mongodb-sink-ingestion || exit;
  helm install connect-mongo-sink-ingestion --set route.name="connect-mongo-sink-ingestion" .
)
(
  cd config || exit;
  sleep 60
  echo -e "Creating MongoDB Sink Ingestion Connector"
  curl -s -X POST -H 'Content-Type: application/json' --data @mongodb-sink-ingestion.json  http://connect-mongo-sink-ingestion.router.default.svc.cluster.local/connectors
)

sleep 180

echo "Collecting results"
ssh -i ~/.ssh/script69 furno@137.121.170.69 'bash -s' < get_results.sh

sleep 120

(
  cd /c/Users/anton/Desktop/kafka-exercise || exit
  mvn exec:java -Dexec.mainClass="unisannio.dist.kafka.ConsumerMain" -Dexec.args="0 mongo"
)

sleep 30