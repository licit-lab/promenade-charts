#!/bin/bash

oc login master.licit.local:8443 --username=licit --password=licit

oc project promenade

artemis() {
  ##Creating artemis here
  (cd activemq-artemis/activemq-artemis || exit
  #
  helm delete artemis
  #
  oc delete pvc data-artemis-activemq-artemis-master-0
  oc delete pvc artemis-activemq-artemis

  helm install artemis .)
}

mongo() {
  (cd mongodb || exit
  #
  helm delete mongodb-replicaset
  #
  oc delete pvc datadir-mongodb-replicaset-0
  oc delete pvc datadir-mongodb-replicaset-1

  helm install mongodb-replicaset .)
}

incorrect_selection() {
  echo "Incorrect selection! Try again."
}

neo4j(){
  echo "to be done"
}

kafka(){
  echo "to be done"
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
  echo "5  -  Execute all"
  echo "0  -  Exit"
  echo ""
  echo -n "Enter selection: "
  read -r selection
  case $selection in
    1 ) artemis ;;
    2 ) mongo ;;
    3 ) kafka ;;
    4 ) neo4j ;;
    5 ) execute_all ;;
    0 ) exit ;;
    * ) incorrect_selection ;;
  esac
done