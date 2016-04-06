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

# Prepare configuration
export CONF=$HADOOP_CONF
export LOG=$CONF/${JOB_NAME}_${JOB_ID}.log
export HADOOP_LOG_DIR=$CONF

echo "start PE STOP `date`" >> $LOG 2>&1
for h in `cat $PE_HOSTFILE | cut -f1 -d' ' `; do
        qrsh -inherit -nostdin -V $h killall -u $USER -w java || echo "Java no found at $h" >> $LOG 2>&1
done

# Make sure the job stops successfully
exit 0
