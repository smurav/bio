#!/bin/bash

CONTAINER=sam2bam

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

ALIGNER=bowtie2
if [ ! -z "$2" ]; then
    ALIGNER=$2
fi
SAMPATH=$SAMPLEPATH/$ALIGNER

OUTFILE=$PREFIX/$1.$CONTAINER.stdout
ERRFILE=$PREFIX/$1.$CONTAINER.stderr
LOGFILE=$PREFIX/$1.$CONTAINER.log

# Каталог для сохранения результатов
if [ -d "${PREFIX}" ]; then
	rm -rfv "${PREFIX}/*"
else
	mkdir "${PREFIX}"
fi

echo 'Преобразование SAM в BAM для образца '$1 > "${LOGFILE}"

if [ "$(docker ps -aq -f status=exited -f name=${CONTAINER})" ]; then
	docker rm $CONTAINER | tee -a "${LOGFILE}"
fi

VOLUME=$(printf %q "$SAMPLEPATH")
CMD="docker run --name ${CONTAINER} -v ${VOLUME}:/data biocontainers/samtools:v1.7.0_cv4 samtools view -F 7 -b -o /data/${CONTAINER}/${1}.${ALIGNER}.bam /data/${ALIGNER}/${1}.${ALIGNER}.sam"
echo $CMD>>"${LOGFILE}"
bash -c "$CMD" 1>"${OUTFILE}" 2>"${ERRFILE}"

END=$(date +%s)
RUNTIME=$((END-START))
eval 'echo $(date -ud "@${RUNTIME}" +"Выполнение заняло %H часов %M минут %S секунд")' | tee -a "${LOGFILE}"

