#!/bin/bash

set -e
echo "===== $HOSTNAME:$0" 1>&2

export JAVA_HOME=/Soft/java/jdk1.6.0_30

echo "HADOOP HOME: $HADOOP_HOME"

echo "Configuring master namenode"
$HADOOP_HOME/bin/hdfs --config `pwd` namenode &

# Pause to let namenode to start and avoid error: "could only be replicated to 0 nodes, instead of 1"
# http://stackoverflow.com/questions/10447743/data-replication-error-in-hadoop
sleep 10

echo "Configuring master datanode"
$HADOOP_HOME/bin/hdfs --config `pwd` datanode &

echo "Configuring master secondarynamenode"
$HADOOP_HOME/bin/hdfs --config `pwd` secondarynamenode &

echo "Configuring master jobtracker"
$HADOOP_HOME/sbin/hadoop-daemons.sh --config `pwd` start jobtracker

echo "Configuring master tasktracker"
$HADOOP_HOME/sbin/hadoop-daemons.sh --config `pwd` start tasktracker
