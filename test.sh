#!/bin/bash

for i in {0..9}
do
  echo "Iteration $i"
  ./menu.sh

  (
    cd /c/Users/anton/Desktop/Promenade/emulatorx || exit
    mvn exec:java -Dexec.mainClass="test.Instantion"
  )

  echo "Now waiting before launching the emulator"

  sleep 20

  ssh -i ~/.ssh/script68 furno@137.121.170.68 'bash -s' < launch_emulator.sh
  echo "Now waiting 6 minutes"
  sleep 360

  ssh -i ~/.ssh/script68 furno@137.121.170.68 'bash -s' < stop_emulator.sh
  echo "Now stopping the emulator"

  sleep 30

  echo "Collecting results"
  ssh -i ~/.ssh/script68 furno@137.121.170.68 'bash -s' < get_results.sh

  sleep 30
done