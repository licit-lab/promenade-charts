FROM ubuntu:latest

#Java
RUN apt-get update && apt-get install -y openjdk-8-jdk
ENV JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"

RUN mkdir -p /usr/local/spark-2.4.5/spark-2.4.5-bin-hadoop2.7
#Just to keep alive the script
RUN mkdir -p /usr/local/spark-2.4.5/watcher
WORKDIR /usr/local/spark-2.4.5/spark-2.4.5-bin-hadoop2.7

RUN mkdir -p /var/log/sparkoutputs

#Spark
COPY ./spark-2.4.5-bin-hadoop2.7 /usr/local/spark-2.4.5/spark-2.4.5-bin-hadoop2.7
COPY ./areanames.txt /usr/local/spark-2.4.5
COPY ./FastBCTest-0.0.1-SNAPSHOT-jar-with-dependencies.jar /usr/local/spark-2.4.5
COPY ./test_script.sh /usr/local/spark-2.4.5
ENV SPARK_HOME="/usr/local/spark-2.4.5/spark-2.4.5-bin-hadoop2.7"

RUN chmod +x /usr/local/spark-2.4.5/test_script.sh

#spark.blockManager.port and spark.driver.port
EXPOSE 7079/tcp
EXPOSE 7078/tcp

WORKDIR /usr/local/spark-2.4.5

VOLUME ['/var/log/sparkoutputs']

#Launch tests
ENTRYPOINT ./test_script.sh
