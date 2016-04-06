# Set a name for the job:
#$ -N hadoop-wordcount-s3
# Set the shell to be used:
#$ -S /bin/bash
# Use these environment variables (must be defined) before calling to qsub:
#$ -v JAVA_HOME,HADOOP_S3_SGE,HADOOP_S3_HOME,HADOOP_S3_CONF,S3_JOB_DIR
# We will receive an e-mail just after the job start and just after the jon end to this e-mail address:
#$ -m bea

set -e

check_exported_vars() {
	for V in JAVA_HOME HADOOP_S3_SGE HADOOP_S3_HOME HADOOP_S3_CONF S3_JOB_DIR
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

echo "===== $HOSTNAME:$0" 1>&2


# Define the base directory for this job
export WORK_DIR="$PWD/$JOB_NAME-$JOB_ID"
mkdir --parents "$WORK_DIR"

# Prepare S3 configuration
export S3="s3://$USER"
export S3CFG="$WORK_DIR/s3cfg.$JOB_ID"
scp @fabre:.s3cfg $S3CFG

# Prepare hadoop environment in local node
cd "$WORK_DIR"
s3cmd -c $S3CFG sync $S3/$HADOOP_S3_SGE/s3-hadoop-env.sh ./
. ./s3-hadoop-env.sh
$WORK_DIR/hadoop_sge/hadoop-pe-start.sh


# Copy job data
JOB_DIR="$WORK_DIR/job"
mkdir --parents "$JOB_DIR"
cd "$JOB_DIR"
s3cmd -c $S3CFG sync $S3/$S3_JOB_DIR/input/ ./input/
INPUT_DIR="$JOB_DIR/input"
RESULT_DIR="$S3_JOB_DIR/output/$JOB_ID"

### Define some working directories inside the HDFS:
INPUT="$JOB_NAME-$JOB_ID-INPUT"
OUTPUT="$JOB_NAME-$JOB_ID-OUTPUT"

### Copy the downloaded books inside the HDFS:
$WORK_DIR/hadoop/bin/hdfs --config $HADOOP_CONF dfs -copyFromLocal ./input /$INPUT

### Do the real job: count all the words in the downloaded books using hadoop:
$WORK_DIR/hadoop/bin/hadoop --config $HADOOP_CONF jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.3.jar wordcount /$INPUT /$OUTPUT/wordcount-output

### Copy the results back to the cluster:
$WORK_DIR/hadoop/bin/hdfs --config $HADOOP_CONF dfs -getmerge /$OUTPUT/wordcount-output ./wordcount-output

### Delete the downloaded books and the result files:
$WORK_DIR/hadoop/bin/hdfs --config $HADOOP_CONF dfs -rm -r -skipTrash /$INPUT
$WORK_DIR/hadoop/bin/hdfs --config $HADOOP_CONF dfs -rm -r -skipTrash /$OUTPUT

$WORK_DIR/hadoop_sge/hadoop-pe-stop.sh

echo "Transfering output to S3 bucket"
s3cmd -c $S3CFG put $JOB_DIR/wordcount-output $S3/$RESULT_DIR/ --recursive
s3cmd -c $S3CFG put $WORK_DIR/hadoop_conf/${JOB_NAME}_${JOB_ID}.log $S3/$RESULT_DIR/ --recursive
cd ..
rm -rf "$WORK_DIR"
