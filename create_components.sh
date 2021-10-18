#!/bin/bash

oc login master.licit.local:8443 --username=licit --password=licit

oc project promenade

spark() {
  ( cd spark-operator/spark || exit; oc apply -f pod.yaml )
}

artemis() {
  helm delete artemis
  oc delete pvc data-artemis-activemq-artemis-master-0
  oc delete pvc artemis-activemq-artemis
  sleep 10
  (
    cd activemq-artemis/activemq-artemis || exit
    helm install artemis .
  )
}

mongo() {
  helm delete mongodb; oc delete pvc mongodb
  sleep 10
  (
    cd mongodb || exit; helm install mongodb .
  )
}

custom_sharded_mongo() {
  helm delete mongodb1 mongodb2;
  (
    cd mongodb || exit;
    helm install mongodb1 --set external.port=31184 .;
    #helm install mongodb2 --set external.port=31185 .;
  )
}

neo4j(){
  echo "to be done"
}

kafka(){
  helm delete kafka
  helm delete kafka-connect-artemis
  helm delete connect-mongodb-sink-ingestion
  helm delete connect-mongodb-sink-processing
  helm delete connect-mongo1-sink-ingestion connect-mongo2-sink-ingestion;
  sleep 10;
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

    sleep 180

    (cd charts/cp-kafka-connect-artemis || exit; helm install kafka-connect-artemis .;)

    (
      cd charts/connect-mongodb-sink-ingestion || exit;
      helm install connect-mongo1-sink-ingestion --set route.name="connect-mongo1-sink-ingestion" .;
      #helm install connect-mongo2-sink-ingestion --set route.name="connect-mongo2-sink-ingestion" .;
    )
  )

  sleep 120
}

artemis;
custom_sharded_mongo;
kafka