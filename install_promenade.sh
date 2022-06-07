#!/bin/bash

#oc login [master.licit.local]:8443 --username=[username] --password=[password]
oc project promenade

install_artemis(){
  (cd activemq-artemis/activemq-artemis || exit; helm install artemis .)
}

install_mongodb(){
  (cd mongodb || exit; helm install mongodb .)
}

install_neo4j(){
  (cd neo4j || exit; helm install neo4j .)
}

install_spark_operator(){
  (cd spark-operator/manifest || exit; oc apply -f operator-cm.yaml)
}

install_spark(){
  (cd spark-operator/promenade || exit; oc apply -f promenade_cluster_cm.yaml)
}

install_kafka(){
  (cd cp-kafka-helm-charts || exit; helm install kafka .)
}

install_kafka_connectors(){
  (cd cp-kafka-helm-charts/charts/cp-kafka-connect-artemis || exit;
  helm install kafka-connect-artemis .)

  (cd cp-kafka-helm-charts/charts/connect-mongodb-sink-ingestion || exit;
  helm install connect-mongo-sink-ingestion .)

  (cd cp-kafka-helm-charts/charts/connect-mongodb-sink-processing || exit;
  helm install connect-mongo-sink-processing .)

  (cd connect-websocket-sink || exit;
  helm install connect-websocket-sink .)
}

configure_kafka_connectors(){
  (cd config || exit;
  printf "\nConfiguring Artemis Source Connector...\n"
  curl -s -X POST -H 'Content-Type: application/json' --data @artemis-source.json  http://connect-artemis-promenade.router.default.svc.cluster.local/connectors

  printf "\nConfiguring MongoDB Sink Ingestion Connector, after 20 seconds...\n"
  sleep 20
  curl -s -X POST -H 'Content-Type: application/json' --data @mongodb-sink-ingestion.json  http://connect-mongo-sink-ingestion.router.default.svc.cluster.local/connectors

  printf "\nConfiguring MongoDB Sink Processing Connector, after 20 seconds...\n"
  sleep 20
  curl -s -X POST -H 'Content-Type: application/json' --data @mongodb-sink-processing.json http://connect-mongo-sink-processing.router.default.svc.cluster.local/connectors

  printf "\nConfiguring Websocket Sink Ingestion Connector, after 20 seconds...\n"
  sleep 20
  curl -s -X POST -H 'Content-Type: application/json' --data @ws-sink.json http://connect-websocket-sink.router.default.svc.cluster.local/connector)
}

printf "\nInstalling Artemis...\n"
install_artemis;

printf "\nInstalling MongoDB, after 20 seconds...\n"
sleep 20
install_mongodb;

printf "\nInstalling Neo4j, after 20 seconds...\n"
sleep 20
install_neo4j;

printf "\nInstalling Spark Operator, after 20 seconds...\n"
sleep 20
install_spark_operator;

printf "\nInstalling Spark, after 20 seconds...\n"
sleep 20
install_spark;

printf "\nInstalling Kafka, Kafka ZooKeeper, and Kafka Center after 20 seconds...\n"
sleep 20
install_kafka;

printf "\nInstalling Kafka Connectors, after 60 seconds...\n"
sleep 60
install_kafka_connectors;

printf "\nConfiguring kafka Connectors, after 90 seconds...\n"
sleep 90
configure_kafka_connectors;
