#!/bin/bash


cd /home/furno/fog-emulator || exit

mvn exec:java -Dexec.mainClass="onlineFogEmulator.Main" &> output.log &