#!/usr/bin/env bash

helm delete kafka

helm delete kafka-connect-artemis

if [[ -n $1 ]]
then
  helm delete kafka-connect-neo4j
fi

helm delete kafka-connect-mongodb

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

cd charts/cp-kafka-connect-artemis || exit

sleep 100

helm install kafka-connect-artemis .

if [[ -n $1 ]]
then
  cd .. || exit
  cd cp-kafka-connect-neo4j/ || exit
  helm install kafka-connect-neo4j .
fi

cd .. || exit

cd cp-kafka-connect-mongodb/ || exit

helm install kafka-connect-mongodb .

#cd cp-kafka-connect-mongodb-sink || exit
#
#helm install kafka-connect-mongodb-sink