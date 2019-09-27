#!/bin/bash

CONTAINER=bowtie2

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

VOLUME=$(printf %q "$SAMPLEPATH")
CMD="docker run --name ${CONTAINER} -v ${VOLUME}:/data biocontainers/bowtie2:v2.3.1_cv1 bowtie2 -p 8 -x /data/GCA_000001405.15_GRCh38_full_analysis_set.fna.bowtie_index -1 /data/${TRIMMER}/${1}_R1_001.${TRIMMER}.fastq.gz -2 /data/${TRIMMER}/${1}_R2_001.${TRIMMER}.fastq.gz -S /data/${CONTAINER}/${1}.${CONTAINER}.sam"
echo $CMD>>"${LOGFILE}"
bash -c "$CMD" 1>"${OUTFILE}" 2>"${ERRFILE}"

END=$(date +%s)
RUNTIME=$((END-START))
eval 'echo $(date -ud "@${RUNTIME}" +"Выполнение заняло %H часов %M минут %S секунд")' | tee -a "${LOGFILE}"
