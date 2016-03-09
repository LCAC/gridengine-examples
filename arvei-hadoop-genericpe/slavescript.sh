#!/bin/bash

set -e
echo "===== $HOSTNAME:$0" 1>&2

export JAVA_HOME=/Soft/java/jdk1.6.0_30

echo "Configuring slave datanode"
$HADOOP_HOME/bin/hdfs --config `pwd` datanode &
echo "Configuring slave tasktracker"
$HADOOP_HOME/sbin/hadoop-daemons.sh --config `pwd` start tasktracker

