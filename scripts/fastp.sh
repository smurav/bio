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
SCRIPTPATH=$(dirname "$SCRIPT")
SAMPLEPATH=$(dirname "$SCRIPTPATH")/samples/$1
PREFIX=$SAMPLEPATH/$CONTAINER
OUTFILE=$PREFIX/$1.$CONTAINER.stdout
ERRFILE=$PREFIX/$1.$CONTAINER.stderr
LOGFILE=$PREFIX/$1.$CONTAINER.log

# Каталог для сохранения результатов
if [ -d "${PREFIX}" ]; then
	rm -rfv "${PREFIX}/*"
else
	mkdir "${PREFIX}"
fi

echo 'Контроль качества и обработка образца '$1 > "${LOGFILE}"

if [ "$(docker ps -aq -f status=exited -f name=${CONTAINER})" ]; then
	docker rm $CONTAINER | tee -a "${LOGFILE}"
fi

VOLUME=$(printf %q "$SAMPLEPATH")
CMD="docker run --name ${CONTAINER} -v ${VOLUME}:/data pgcbioinfo/fastp:latest fastp -i /data/${1}_R1_001.fastq.gz -I /data/${1}_R2_001.fastq.gz -o /data/${CONTAINER}/${1}_R1_001.${CONTAINER}.fastq.gz -O /data/${CONTAINER}/${1}_R2_001.${CONTAINER}.fastq.gz -j /data/${CONTAINER}/${1}.${CONTAINER}.json -h /data/${CONTAINER}/${1}.${CONTAINER}.html --adapter_fasta=/data/${1}.adapters.fa -f 6 -t 4 -w 7 -c"
echo $CMD>>"${LOGFILE}"
bash -c "$CMD" 1>"${OUTFILE}" 2>"${ERRFILE}"

END=$(date +%s)
RUNTIME=$((END-START))
eval 'echo $(date -ud "@${RUNTIME}" +"Выполнение заняло %H часов %M минут %S секунд")' | tee -a "${LOGFILE}"

