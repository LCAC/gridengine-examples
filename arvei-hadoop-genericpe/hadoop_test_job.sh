# Set a name for the job:
#$ -N hadoop_test_job
# Set the shell to be used:
#$ -S /bin/bash
# Use these environment variables (must be defined) before calling to qsub:
#$ -v ARVEI_NAS_DIR,ARVEI_JOB_DIR,JAVA_HOME,HADOOP_HOME,HADOOP_CONF
# We will receive an e-mail just after the job start and just after the jon end to this e-mail address:
#$ -m bea

set -e

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

echo "===== $HOSTNAME:$0" 1>&2

# Define the base directory for this job
INPUT_DIR=$ARVEI_JOB_DIR/input
RESULT_DIR=$ARVEI_JOB_DIR/output/$JOB_NAME/$JOB_ID
mkdir --parents $RESULT_DIR

$ARVEI_JOB_DIR/hadoop-pe-start.sh

### Define some working directories inside the HDFS:
INPUT="$JOB_NAME-$JOB_ID-INPUT"
OUTPUT="$JOB_NAME-$JOB_ID-OUTPUT"

### Copy the downloaded books inside the HDFS:
${HADOOP_HOME}/bin/hdfs --config $HADOOP_CONF dfs -copyFromLocal $INPUT_DIR /$INPUT

### Do the real job: count all the words in the downloaded books using hadoop:
${HADOOP_HOME}/bin/hadoop --config $HADOOP_CONF jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.3.jar wordcount /$INPUT /$OUTPUT/wordcount-output

### Copy the results back to the cluster:
${HADOOP_HOME}/bin/hdfs --config $HADOOP_CONF dfs -getmerge /$OUTPUT/wordcount-output $RESULT_DIR/wordcount-output

### Delete the downloaded books and the result files:
${HADOOP_HOME}/bin/hdfs --config $HADOOP_CONF dfs -rm -r -skipTrash /$INPUT
${HADOOP_HOME}/bin/hdfs --config $HADOOP_CONF dfs -rm -r -skipTrash /$OUTPUT

$ARVEI_JOB_DIR/hadoop-pe-stop.sh
