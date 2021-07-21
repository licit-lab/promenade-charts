#!/usr/bin/env bash

helm delete kafka

helm delete kafka-connect-artemis

helm delete connect-mongodb-sink-ingestion

helm delete connect-mongodb-sink-processing

if [[ -n $1 ]]
then
  helm delete kafka-connect-neo4j
fi

oc delete pvc datadir-kafka-cp-zookeeper-2
oc delete pvc datadir-kafka-cp-zookeeper-1
oc delete pvc datadir-kafka-cp-zookeeper-0
oc delete pvc datadir-0-kafka-cp-kafka-2
oc delete pvc datadir-0-kafka-cp-kafka-1
oc delete pvc datadir-0-kafka-cp-kafka-0
oc delete pvc datalogdir-kafka-cp-zookeeper-0
oc delete pvc datalogdir-kafka-cp-zookeeper-1
oc delete pvc datalogdir-kafka-cp-zookeeper-2

helm install kafka .

(cd charts/cp-kafka-connect-artemis || exit

sleep 100

helm install kafka-connect-artemis .)

if [[ -n $1 ]]
then
  cd .. || exit
  cd cp-kafka-connect-neo4j/ || exit
  helm install kafka-connect-neo4j .
fi

(cd charts/connect-mongodb-sink-ingestion || exit

helm install connect-mongodb-sink-ingestion .)

(cd charts/connect-mongodb-sink-processing || exit

helm install connect-mongodb-sink-processing .)