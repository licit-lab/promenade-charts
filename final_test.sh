#!/bin/bash

for i in {0..0}
do
  printf 'Iteration %s' "$i"
  ./create_components.sh

  printf "Statically creating Kafka topics and Mongo collections\n"
  (
    cd /c/Users/anton/Desktop/Promenade/static-configurator || exit
    mvn exec:java -Dexec.mainClass="configuration.StaticCreation"
  )

  printf "Create connectors\n"
  (
      cd config || exit;
      printf "Creating Artemis Source Connector\n"
      curl -s -X POST -H 'Content-Type: application/json' --data @artemis-source.json  http://connect-artemis-promenade.router.default.svc.cluster.local/connectors
      printf "\nCreating MongoDB1 Sink Ingestion Connector\n"
      curl -s -X POST -H 'Content-Type: application/json' --data @mongodb1-sink-ingestion.json  http://connect-mongo1-sink-ingestion.router.default.svc.cluster.local/connectors
      #printf "\nCreating MongoDB2 Sink Ingestion Connector\n"
      #curl -s -X POST -H 'Content-Type: application/json' --data @mongodb2-sink-ingestion.json  http://connect-mongo2-sink-ingestion.router.default.svc.cluster.local/connectors
  )

  printf "Now waiting 20 seconds before launching the emulator\n"

  sleep 20

  ssh -i ~/.ssh/script69 furno@137.121.170.69 'bash -s' < launch_emulator.sh
  printf "Now waiting 240 seconds\n"
  sleep 240

  ssh -i ~/.ssh/script69 furno@137.121.170.69 'bash -s' < stop_emulator.sh
  printf "Now stopping the emulator and waiting 30 seconds\n"

  sleep 30

  printf "Collecting results from kafka\n"
  (
    cd /c/Users/anton/Desktop/kafka-exercise || exit
    mvn exec:java -Dexec.mainClass="unisannio.dist.kafka.ParallelConsumers" -Dexec.args="0 mongo"
  )

#  echo "Collecting results"
#  ssh -i ~/.ssh/script69 furno@137.121.170.69 'bash -s' < get_results.sh

done