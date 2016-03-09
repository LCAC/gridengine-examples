# Set a name for the job:
#$ -N hadoop_test_job
# Set the shell to be used:
#$ -S /bin/bash
# Select a concrete version of hadoop to be used (mandatory):
#$ -v JAVA_HOME=/Soft/java/jdk1.6.0_30,HADOOP_HOME=/scratch/nas/1/alexm/hadoop-genericpe/soft/hadoop-2.6.3,HADOOP_CONF=/scratch/nas/1/alexm/hadoop-genericpe/conf
# We will receive an e-mail just after the job start and just after the jon end to this e-mail address:
#$ -m bea
#$ -M alexm@ac.upc.edu

set -e
echo "===== $HOSTNAME:$0" 1>&2

# Define the base directory for this job
BASE_DIR=/scratch/nas/1/alexm/hadoop-genericpe
BOOKS_DIR=$BASE_DIR/books
RESULT_DIR=$BASE_DIR/output/$JOB_NAME/$JOB_ID
CONFIG_DIR=$BASE_DIR/conf
mkdir --parents $RESULT_DIR

export BASE_DIR
export JAVA_HOME

$BASE_DIR/hadoop-pe-start.sh

### Define some working directories inside the HDFS:
INPUT="$JOB_NAME-$JOB_ID-INPUT"
OUTPUT="$JOB_NAME-$JOB_ID-OUTPUT"

### Copy the downloaded books inside the HDFS:
${HADOOP_HOME}/bin/hdfs --config $CONFIG_DIR dfs -copyFromLocal $BOOKS_DIR /$INPUT

### Do the real job: count all the words in the downloaded books using hadoop:
${HADOOP_HOME}/bin/hadoop --config $CONFIG_DIR jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.3.jar wordcount /$INPUT /$OUTPUT/wordcount-output

### Copy the results back to the cluster:
${HADOOP_HOME}/bin/hdfs --config $CONFIG_DIR dfs -getmerge /$OUTPUT/wordcount-output $RESULT_DIR/wordcount-output

### Delete the downloaded books and the result files:
${HADOOP_HOME}/bin/hdfs --config $CONFIG_DIR dfs -rm -r -skipTrash /$INPUT
${HADOOP_HOME}/bin/hdfs --config $CONFIG_DIR dfs -rm -r -skipTrash /$OUTPUT

$BASE_DIR/hadoop-pe-stop.sh
