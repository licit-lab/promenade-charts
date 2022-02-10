#!/bin/bash

#oc login [master.licit.local]:8443 --username=[username] --password=[password]
oc project promenade

uninstall_artemis(){
  helm uninstall artemis
  oc delete pvc data-artemis-activemq-artemis-master-0
  #oc delete pvc artemis-activemq-artemis
}

uninstall_mongodb(){
  helm uninstall mongodb
  #oc delete pvc mongodb
}

uninstall_neo4j(){
  helm uninstall neo4j
  oc delete pvc datadir-neo4j-neo4j-core-0
  oc delete pvc datadir-neo4j-neo4j-core-1
  oc delete pvc datadir-neo4j-neo4j-core-2
}

uninstall_spark(){
  #oc get configmaps
  oc delete configmap promenade-cluster
}

uninstall_spark_operator(){
  #oc get deployments
  oc delete deployment spark-operator
}

uninstall_kafka(){
  helm uninstall kafka

  oc delete pvc datadir-0-kafka-cp-kafka-0
  oc delete pvc datadir-0-kafka-cp-kafka-1
  oc delete pvc datadir-0-kafka-cp-kafka-2

  oc delete pvc datadir-kafka-cp-zookeeper-0
  oc delete pvc datadir-kafka-cp-zookeeper-1
  oc delete pvc datadir-kafka-cp-zookeeper-2

  oc delete pvc datalogdir-kafka-cp-zookeeper-0
  oc delete pvc datalogdir-kafka-cp-zookeeper-1
  oc delete pvc datalogdir-kafka-cp-zookeeper-2
}

uninstall_kafka_connectors(){
  helm uninstall kafka-connect-artemis
  helm uninstall connect-mongo-sink-ingestion
  helm uninstall connect-mongo-sink-processing
}

uninstall_artemis;
uninstall_mongodb;
uninstall_neo4j;
uninstall_spark;
uninstall_spark_operator;
uninstall_kafka;
uninstall_kafka_connectors;