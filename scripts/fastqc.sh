#!/bin/bash
if [ -z "$1" ]; then
    echo "Укажите идентификатор образца"
    exit -1
fi

CONTAINER=fastqc

START=$(date +%s)
BASENAME=$(basename -- "$0")
FILENAME="${BASENAME%.*}"
SCRIPT=$(readlink -f $0)
SCRIPTPATH=$(dirname $SCRIPT)
SAMPLEPATH=$(dirname $SCRIPTPATH)/samples/$1
PREFIX=$SAMPLEPATH/$1
OUTFILE=$PREFIX.$CONTAINER.stdout
ERRFILE=$PREFIX.$CONTAINER.stderr
LOGFILE=$PREFIX.$CONTAINER.log
echo 'Контроль качества образца '$1 > $LOGFILE

if [ "$(docker ps -aq -f status=exited -f name=${CONTAINER})" ]; then
	docker rm $CONTAINER
fi

CMD="docker run -v ${SAMPLEPATH}:/data --name ${CONTAINER} biocontainers/fastqc:v0.11.5_cv4 fastqc ${1}_R1_001.fastq.gz ${1}_R2_001.fastq.gz -t 7 --noextract"
echo $CMD>>$LOGFILE
$CMD 1>$OUTFILE 2>$ERRFILE

END=$(date +%s)
RUNTIME=$((END-START))
eval "echo $(date -ud "@${RUNTIME}" +'Выполнение заняло %H часов %M минут %S секунд')" | tee -a $LOGFILE
