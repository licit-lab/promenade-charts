#!/bin/bash

printf "Running the test...\n"
(cd promenade-charts/spark-operator/spark || exit; oc apply -f pod.yaml)

(cd fog-emulator/ || exit 
mvn exec:java -Dexec.mainClass="onlineFogEmulator.Main")