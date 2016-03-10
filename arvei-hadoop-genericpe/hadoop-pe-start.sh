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

# Request exclusive node access
qalter -l genericpe_master=1

# Define variables
export SGE_HADOOP_DIR=$ARVEI_JOB_DIR

JPS="$JAVA_HOME/bin/jps"
## we get HADOOP_HOME and HADOOP_CONF from jobs env
cd $HADOOP_HOME

# Prepare configuration
export CONF=$HADOOP_CONF
export LOG=$CONF/${JOB_NAME}_${JOB_ID}.log
export HADOOP_LOG_DIR=$CONF

# Define master node
#master=`head -1 $PE_HOSTFILE | cut -f1 -d' '`
master=`hostname`
echo $master > $CONF/masters

# Prepare slaves file
tail -n +2 $PE_HOSTFILE | cut -f1 -d'.' > $CONF/slaves
slave_cnt=`cat $CONF/slaves|wc -l`

##In ideal cases mtasks=10xslaves, rtasks=2xslaves, tpn=2perslave
tpn=`expr $NSLOTS \\/ $slave_cnt`

# Replication number
replications=`expr $NSLOTS - 1`

# Where store hdfs
#tmphdfs=`echo $TMPDIR | sed 's/\//\\\\\//g'`
tmphdfs="\\/scratch\\/1\\/$USER\\/hadoop_hdfs.$JOB_ID"

# Modify templates
for file in hdfs-site mapred-site core-site; do
	sed -e "s/HADOOP_MASTER_HOST/$master/g" -e "s/HDFSPORT/54310/g" -e "s/HMPRPORT/54311/g" -e "s/HMTASKS/$NSLOTS/g" -e "s/HRTASKS/$NSLOTS/g" -e "s/HTPN/$tpn/g" -e "s/HTMPDIR/$tmphdfs/g" -e "s/HDFSREPLICATIONS/$replications/g" $CONF/$file-template.xml > $CONF/$file.xml
done


### Format namenode
FILEYES=/tmp/yes.$$
echo 'Y' > $FILEYES
bin/hdfs --config $CONF namenode -format < $FILEYES >> $LOG 2>&1
rm -f $FILEYES


# Start master processes
echo "Configuring master node: $master" >> $LOG 2>&1
cd $CONF
$SGE_HADOOP_DIR/masterscript.sh >> $LOG 2>&1 

sleep 2


# Start slave processes
newslaves=`cat $CONF/slaves | grep -v "$( cat $CONF/masters )"`
for i in `echo $newslaves`; do
	echo "Configuring slave node: $i" >> $LOG 2>&1
	qrsh -inherit -nostdin -V $i "cd $CONF; $SGE_HADOOP_DIR/slavescript.sh" >> $LOG 2>&1 &
done

sleep 2


echo "Testing jps jobs:" >> $LOG 2>&1
for h in `cat $PE_HOSTFILE | cut -f1 -d' ' `; do
        echo "Jobs a $h:" >> $LOG 2>&1
        qrsh -inherit -nostdin -V $h jps >> $LOG 2>&1
done

### Is there a better way to do this, may be use jstatd and use jps <slave>
### wait for dfs daemons to start in master
### 3 = NameNode, DataNode, SecondaryNameNode
dcnt=0
while [ $dcnt -lt 3 ]
do
	sleep 1
	dcnt=`$JPS | grep -v Jps | wc -l`
done
