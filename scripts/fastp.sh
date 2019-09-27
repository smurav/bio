#!/bin/bash

CONTAINER=fastp

if [ -z "$1" ]; then
    echo "Укажите идентификатор образца"
    exit -1
fi

START=$(date +%s)
BASENAME=$(basename -- "$0")
FILENAME="${BASENAME%.*}"
SCRIPT=$(readlink -f $0)
SCRIPTPATH=$(dirname $SCRIPT)
SAMPLEPATH=$(dirname $SCRIPTPATH)/samples/$1
PREFIX=$SAMPLEPATH/$1/$CONTAINER
OUTFILE=$PREFIX.$CONTAINER.stdout
ERRFILE=$PREFIX.$CONTAINER.stderr
LOGFILE=$PREFIX.$CONTAINER.log

# Каталог для сохранения результатов
if [ -d $PREFIX ]; then
	rm -rfv "${PREFIX}/*"
else
	mkdir "${PREFIX}"
fi

echo 'Контроль качества и обработка образца '$1 > $LOGFILE

if [ "$(docker ps -aq -f status=exited -f name=${CONTAINER})" ]; then
	docker rm $CONTAINER | tee -a $LOGFILE
fi

CMD="docker run -v ${SAMPLEPATH}:/data --name ${CONTAINER} 
pgcbioinfo/fastp fastp 
-i /data/${1}_R1_001.fastq.gz 
-I /data/${1}_R2_001.fastq.gz 
-o /data/${1}_R1_001.${CONTAINER}.fastq.gz 
-O /data/${1}_R2_001.${CONTAINER}.fastq.gz 
-j /data/${CONTAINER}/${1}.${CONTAINER}.json 
-h /data/${CONTAINER}/${1}.${CONTAINER}.html
--adapter_fasta=/data/${1}.adapters.fa -f 6 -t 4 -w 7 -c"
echo $CMD>>$LOGFILE
$CMD 1>$OUTFILE 2>$ERRFILE

END=$(date +%s)
RUNTIME=$((END-START))
eval "echo $(date -ud "@${RUNTIME}" +'Выполнение заняло %H часов %M минут %S секунд')" | tee -a $LOGFILE
