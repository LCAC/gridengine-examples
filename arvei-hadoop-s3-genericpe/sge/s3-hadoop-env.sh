#!/bin/bash

set -e

check_exported_vars() {
	for V in JAVA_HOME HADOOP_S3_SGE HADOOP_S3_HOME HADOOP_S3_CONF
	do
		if eval "test -z \"\$$V\""
		then
			echo "ERROR! Environment variable $V must be defined." 1
>&2
			exit 1
		fi
	done
}

# Check for mandatory variables
check_exported_vars

# Define Hadoop local dir
export HADOOP_HOME="$WORK_DIR/hadoop"
mkdir --parents "$HADOOP_HOME"
cd $HADOOP_HOME
s3cmd -c $S3CFG sync $S3/$HADOOP_S3_HOME/ ./

export HADOOP_CONF="$WORK_DIR/hadoop_conf"
mkdir --parents "$HADOOP_CONF"
cd $HADOOP_CONF
s3cmd -c $S3CFG sync $S3/$HADOOP_S3_CONF/ ./

export HADOOP_SGE_NODE="$WORK_DIR/hadoop_sge"
mkdir --parents "$HADOOP_SGE_NODE"
cd "$HADOOP_SGE_NODE"
s3cmd -c $S3CFG sync $S3/$HADOOP_S3_SGE/ ./

