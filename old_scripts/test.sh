#!/bin/bash

for i in {0..0}
do
  echo "Iteration $i"
  ./menu.sh

  (
    cd /c/Users/anton/Desktop/Promenade/static-configurator || exit
    mvn exec:java -Dexec.mainClass="configuration.StaticCreation"
  )

  (
      cd config || exit;
      echo -e "Creating Artemis Source Connector"
      curl -s -X POST -H 'Content-Type: application/json' --data @artemis-source.json  http://connect-artemis-promenade.router.default.svc.cluster.local/connectors
      echo -e "Creating MongoDB Sink Ingestion Connector"
      curl -s -X POST -H 'Content-Type: application/json' --data @mongodb1-sink-ingestion.json  http://connect-mongo1-sink-ingestion.router.default.svc.cluster.local/connectors
      #sleep 10
      #curl -s -X POST -H 'Content-Type: application/json' --data @mongodb2-sink-ingestion.json  http://connect-mongo2-sink-ingestion.router.default.svc.cluster.local/connectors
  )

  echo "Now waiting before launching the emulator"

  sleep 20

  ssh -i ~/.ssh/script69 furno@137.121.170.69 'bash -s' < launch_emulator.sh
  echo "Now waiting 6 minutes"
  sleep 360

  ssh -i ~/.ssh/script69 furno@137.121.170.69 'bash -s' < stop_emulator.sh
  echo "Now stopping the emulator"

  sleep 30

  ./test_custom_sharded_mongo.sh

#  echo "Collecting results"
#  ssh -i ~/.ssh/script69 furno@137.121.170.69 'bash -s' < get_results.sh

#  (
#    cd /c/Users/anton/Desktop/kafka-exercise || exit
#    mvn exec:java -Dexec.mainClass="unisannio.dist.kafka.ConsumerMain" -Dexec.args="$i artemis"
#  )

#  sleep 30
done