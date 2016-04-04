# Set a name for the job:
#$ -N hadoop-wordcount
# Set the shell to be used:
#$ -S /bin/bash
# Use these environment variables (must be defined) before calling to qsub:
#$ -v ARVEI_JOB_DIR,JAVA_HOME,HADOOP_HOME,HADOOP_CONF
# We will receive an e-mail just after the job start and just after the jon end to this e-mail address:
#$ -m bea

set -e

check_exported_vars() {
	for V in ARVEI_JOB_DIR JAVA_HOME HADOOP_HOME HADOOP_CONF
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
S3="s3://$USER"
INPUT_DIR=$ARVEI_JOB_DIR/input
RESULT_DIR=$ARVEI_JOB_DIR/output/$JOB_NAME/$JOB_ID

WORK_DIR="$PWD/$JOB_NAME-$JOB_ID"
mkdir --parents "$WORK_DIR"
cd "$WORK_DIR"

# Copy job data
s3cmd sync $S3/$JOB_NAME/ .
./s3-hadoop-pe-start.sh

### Define some working directories inside the HDFS:
INPUT="$JOB_NAME-$JOB_ID-INPUT"
OUTPUT="$JOB_NAME-$JOB_ID-OUTPUT"

### Copy the downloaded books inside the HDFS:
./hadoop/bin/hdfs --config ./conf dfs -copyFromLocal ./input /$INPUT

### Do the real job: count all the words in the downloaded books using hadoop:
./hadoop/bin/hadoop --config ./conf jar ./hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.3.jar wordcount /$INPUT /$OUTPUT/wordcount-output

### Copy the results back to the cluster:
./hadoop/bin/hdfs --config ./conf dfs -getmerge /$OUTPUT/wordcount-output ./wordcount-output

### Delete the downloaded books and the result files:
./hadoop/bin/hdfs --config ./conf dfs -rm -r -skipTrash /$INPUT
./hadoop/bin/hdfs --config ./conf dfs -rm -r -skipTrash /$OUTPUT

./s3-hadoop-pe-stop.sh

s3cmd put wordcount-output $S3/$RESULT_DIR/ --recursive
cd ..
rm -rf "$WORK_DIR"
