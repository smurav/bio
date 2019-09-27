#!/bin/bash
if [ -z "$1" ]; then
    echo "Укажите идентификатор образца"
    exit -1
fi

CONTAINER=bowtie2

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
echo 'Выравнивание образца ${1} по референсному геному ' > $LOGFILE

if [ "$(docker ps -aq -f status=exited -f name=${CONTAINER})" ]; then
	docker rm $CONTAINER
fi

CMD="docker run -v ${SAMPLEPATH}:/data --name ${CONTAINER} 
biocontainers/bowtie2:v2.3.1_cv1 bowtie2 -p 8 
-x GCA_000001405.15_GRCh38_full_analysis_set.fna.bowtie_index 
-1 /data/${1}_R1_001.fp.fq.gz 
-2 /data/${1}_R2_001.fp.fq.gz 
-S /data/${1}.bt2.sam"
echo $CMD>>$LOGFILE
$CMD 1>$OUTFILE 2>$ERRFILE

END=$(date +%s)
RUNTIME=$((END-START))
eval "echo $(date -ud "@${RUNTIME}" +'Выполнение заняло %H часов %M минут %S секунд')" | tee -a $LOGFILE
