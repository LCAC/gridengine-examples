#!/bin/bash

set -e
echo "===== $HOSTNAME:$0" 1>&2

DIRNAS=1
while [ ! -d /scratch/nas/$DIRNAS/$USER ] && [ $DIRNAS -lt 10 ] ; do
        let DIRNAS=DIRNAS+1
done

# Prepare configuration
if [ "X" = "X$HADOOP_CONF" ] ; then
        export CONF=/scratch/nas/$DIRNAS/$USER/hadoop_config.$JOB_ID
else
	export CONF=$HADOOP_CONF
fi

export LOG=$CONF/${JOB_NAME}_${JOB_ID}.log
export HADOOP_LOG_DIR=$CONF

echo "start PE STOP `date`" >> $LOG 2>&1
for h in `cat $PE_HOSTFILE | cut -f1 -d' ' `; do
        qrsh -inherit -nostdin -V $h killall -u $USER -w java >> $LOG 2>&1
done

# Make sure the job stops successfully
exit 0

### Start hdfs and mapred daemons

