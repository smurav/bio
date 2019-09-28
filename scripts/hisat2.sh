#!/bin/bash

CONTAINER=hisat2

if [ -z "$1" ]; then
    echo "Укажите идентификатор образца"
    exit -1
fi

START=$(date +%s)
BASENAME=$(basename -- "$0")
FILENAME="${BASENAME%.*}"
SCRIPT=$(readlink -f $0)
SCRIPTPATH=$(dirname "$SCRIPT")
SAMPLEPATH=$(dirname "$SCRIPTPATH")/samples
VOLUME=$(printf %q "$SAMPLEPATH")
PREFIX=$SAMPLEPATH/$1/$CONTAINER

TRIMMER=fastp
if [ ! -z "$2" ]; then
    TRIMMER=$2
fi

OUTFILE=$PREFIX/$1.$CONTAINER.stdout
ERRFILE=$PREFIX/$1.$CONTAINER.stderr
LOGFILE=$PREFIX/$1.$CONTAINER.log

# Каталог для сохранения результатов
if [ -d "${PREFIX}" ]; then
	rm -rfv "${PREFIX}/*"
else
	mkdir "${PREFIX}"
fi

echo "Выравнивание образца ${1} по референсному геному" > "${LOGFILE}"

if [ "$(docker ps -aq -f status=exited -f name=${CONTAINER})" ]; then
	docker rm $CONTAINER | tee -a "${LOGFILE}"
fi

CMD="docker run --name ${CONTAINER} -v ${VOLUME}:/data \
greatfireball/hisat2 hisat2 -p 7 \
-x /data/GCA_000001405.15_GRCh38_full_analysis_set \
-1 /data/${1}/${TRIMMER}/${1}_R1_001.${TRIMMER}.fastq.gz \
-2 /data/${1}/${TRIMMER}/${1}_R2_001.${TRIMMER}.fastq.gz \ \
-S /data/${1}/${CONTAINER}/${1}.${CONTAINER}.sam \
-t --no-unal --mm --rg-id ${1} --rg DT:05-08-2019 --rg SM:${1} \
--rg PL:Illumina \
--summary-file /data/${1}/${CONTAINER}/${1}.${CONTAINER}.summary \
--met-file /data/${1}/${CONTAINER}/${1}.${CONTAINER}.metrics"
echo $CMD>>"${LOGFILE}"
bash -c "$CMD" 1>"${OUTFILE}" 2>"${ERRFILE}"

END=$(date +%s)
RUNTIME=$((END-START))
eval 'echo $(date -ud "@${RUNTIME}" +"Выполнение заняло %H часов %M минут %S секунд")' | tee -a "${LOGFILE}"
