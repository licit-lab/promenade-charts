#!/bin/bash

oc login master.licit.local:8443 --username=licit --password=licit

oc project promenade

spark() {
  ( cd spark-operator/spark || exit; oc apply -f pod.yaml )
}

artemis() {
  (cd activemq-artemis/activemq-artemis || exit
  helm delete artemis
  oc delete pvc data-artemis-activemq-artemis-master-0
  oc delete pvc artemis-activemq-artemis
  helm install artemis .)
}

mongo() {
  helm delete mongodb1; oc delete pvc mongodb1
  (cd mongodb || exit; helm install mongodb1 .)
}

incorrect_selection() {
  echo "Incorrect selection! Try again."
}

neo4j(){
  echo "to be done"
}

kafka(){
  helm delete kafka
  helm delete kafka-connect-artemis
  helm delete connect-mongodb-sink-ingestion
  helm delete connect-mongodb-sink-processing
  oc delete pvc datadir-kafka-cp-zookeeper-2
  oc delete pvc datadir-kafka-cp-zookeeper-1
  oc delete pvc datadir-kafka-cp-zookeeper-0
  oc delete pvc datadir-0-kafka-cp-kafka-2
  oc delete pvc datadir-0-kafka-cp-kafka-1
  oc delete pvc datadir-0-kafka-cp-kafka-0
  oc delete pvc datalogdir-kafka-cp-zookeeper-0
  oc delete pvc datalogdir-kafka-cp-zookeeper-1
  oc delete pvc datalogdir-kafka-cp-zookeeper-2

  (
    cd cp-kafka-helm-charts || exit; helm install kafka .

    (cd charts/cp-kafka-connect-artemis || exit; sleep 130; helm install kafka-connect-artemis .)

    (cd charts/connect-mongodb-sink-ingestion || exit; helm install connect-mongodb-sink-ingestion .)

    (cd charts/connect-mongodb-sink-processing || exit; helm install connect-mongodb-sink-processing .)
  )

  sleep 90

  (cd config || exit;
  echo -e "Creating Artemis Source Connector"
  curl -s -X POST -H 'Content-Type: application/json' --data @artemis-source.json  http://connect-artemis-promenade.router.default.svc.cluster.local/connectors
  sleep 10
  echo -e "Creating MongoDB Sink Ingestion Connector"
  curl -s -X POST -H 'Content-Type: application/json' --data @mongodb-sink-ingestion.json  http://connect-mongo-sink-ingestion.router.default.svc.cluster.local/connectors
  sleep 10
  echo -e "Creating MongoDB Sink Processing Connector"
  curl -s -X POST -H 'Content-Type: application/json' --data @mongodb-sink-processing.json  http://connect-mongo-sink-processing.router.default.svc.cluster.local/connectors)
}

execute_all(){
  artemis;
  mongo;
  kafka;
}

until [ "$selection" = "0" ]; do
  echo "1  -  Artemis"
  echo "2  -  Mongo"
  echo "3  -  Kafka"
  echo "4  -  Neo4j"
  echo "5 -   Spark"
  echo "6  -  Execute all"
  echo "0  -  Exit"
  echo ""
  echo -n "Enter selection: "
  read -r selection
  case $selection in
    1 ) artemis ;;
    2 ) mongo ;;
    3 ) kafka ;;
    4 ) neo4j ;;
    5 ) spark ;;
    6 ) execute_all ;;
    0 ) exit ;;
    * ) incorrect_selection ;;
  esac
done