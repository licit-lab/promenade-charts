#!/bin/bash

cd /home/furno/fog-emulator || exit

ps -aux | grep 'mvn\|java' | kill -9 $(awk '{print $2}'); rm -rf output.log *_logs.csv
