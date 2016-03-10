#!/bin/bash

set -e
echo "===== $HOSTNAME:$0" 1>&2

check_exported_vars() {
        for V in ARVEI_NAS_DIR ARVEI_JOB_DIR JAVA_HOME HADOOP_HOME HADOOP_CONF
        do
                if eval "test -z \"\$$V\""
                then
                        echo "ERROR! Environment variable $V must be defined." 1>&2
                        exit 1
                fi
        done
}

# Check for mandatory variables
check_exported_vars

echo "Configuring master namenode"
$HADOOP_HOME/bin/hdfs --config "$PWD" namenode &

# Pause to let namenode to start and avoid error: "could only be replicated to 0 nodes, instead of 1"
# http://stackoverflow.com/questions/10447743/data-replication-error-in-hadoop
sleep 10

echo "Configuring master datanode"
$HADOOP_HOME/bin/hdfs --config "$PWD" datanode &

echo "Configuring master secondarynamenode"
$HADOOP_HOME/bin/hdfs --config "$PWD" secondarynamenode &

echo "Configuring master jobtracker"
$HADOOP_HOME/sbin/hadoop-daemons.sh --config "$PWD" start jobtracker

echo "Configuring master tasktracker"
$HADOOP_HOME/sbin/hadoop-daemons.sh --config "$PWD" start tasktracker
