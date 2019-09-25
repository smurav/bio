#!/bin/bash
if [ -z "$1" ]; then
    echo "Укажите идентификатор образца"
    exit -1
fi

CONTAINER=fastp

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
echo 'Контроль качества и обработка образца '$1 > $LOGFILE

if [ "$(docker ps -aq -f status=exited -f name=${CONTAINER})" ]; then
	docker rm $CONTAINER
fi

CMD="docker run -v ${SAMPLEPATH}:/data --name ${CONTAINER} pgcbioinfo/fastp fastp -i /data/${1}_R1_001.fastq.gz -I /data/${1}_R2_001.fastq.gz -o /data/${1}_R1_001.fp.fq.gz -O /data/${1}_R2_001.fp.fq.gz --adapter_fasta=/data/${1}.adapters.fa -f 6 -t 4 -c -g -x -p"
echo $CMD>>$LOGFILE
$CMD 1>$OUTFILE 2>$ERRFILE

END=$(date +%s)
RUNTIME=$((END-START))
eval "echo $(date -ud "@${RUNTIME}" +'Выполнение заняло %H часов %M минут %S секунд')" | tee -a $LOGFILE
