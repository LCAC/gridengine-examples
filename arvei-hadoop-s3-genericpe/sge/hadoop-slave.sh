#!/bin/bash

set -e
echo "===== $HOSTNAME:$0" 1>&2

check_exported_vars() {
        for V in JAVA_HOME HADOOP_HOME HADOOP_CONF
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

echo "Configuring slave datanode"
$HADOOP_HOME/bin/hdfs --config "$PWD" datanode &
echo "Configuring slave tasktracker"
$HADOOP_HOME/sbin/hadoop-daemons.sh --config "$PWD" start tasktracker
