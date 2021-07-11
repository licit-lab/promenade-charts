#!/usr/bin/env bash

oc login master.licit.local:8443 --username=licit --password=licit

oc project promenade

#(cd mongodb || exit
#
#helm delete mongodb-replicaset
#
#oc delete pvc datadir-mongodb-replicaset-0
#oc delete pvc datadir-mongodb-replicaset-1
#
#helm install mongodb-replicaset .)

#Creating artemis here
(cd activemq-artemis/activemq-artemis || exit

helm delete artemis

oc delete pvc data-artemis-activemq-artemis-master-0
oc delete pvc artemis-activemq-artemis

helm install artemis .)

#(cd neo4j || exit
#helm delete neo4j
#oc delete pvc datadir-neo4j-neo4j-core-2
#oc delete pvc datadir-neo4j-neo4j-core-1
#oc delete pvc datadir-neo4j-neo4j-core-0
##oc delete pvc datadir-mongodb-replicaset-0
#helm install neo4j .)

(cd cp-kafka-helm-charts || exit; ./kafka_launch_script.sh)

sleep 90

###Create connectors instances

(cd config || exit;
echo -e "Creating Artemis Source Connector"
curl -s -X POST -H 'Content-Type: application/json' --data @artemis-source.json  http://connect-artemis-promenade.router.default.svc.cluster.local/connectors
echo -e "Creating MongoDB Sink Connector"
curl -s -X POST -H 'Content-Type: application/json' --data @mongodb-sink.json  http://connect-mongo-promenade.router.default.svc.cluster.local/connectors)