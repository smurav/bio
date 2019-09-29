#!/bin/bash

if [ -z "$1" ]; then
    echo "Укажите идентификатор образца"
    exit -1
fi

START=$(date +%s)
BASENAME=$(basename -- "$0")
CONTAINER="${BASENAME%.*}"
SCRIPT=$(readlink -f $0)
SCRIPTPATH=$(dirname "$SCRIPT")
SAMPLEPATH=$(dirname "$SCRIPTPATH")/samples/$1

ALIGNER=bowtie2
if [ ! -z "$2" ]; then
    ALIGNER=$2
fi

PREFIX=$SAMPLEPATH/$CONTAINER_$ALIGNER

OUTFILE=$PREFIX/$1.$CONTAINER.stdout
ERRFILE=$PREFIX/$1.$CONTAINER.stderr
LOGFILE=$PREFIX/$1.$CONTAINER.log

# Каталог для сохранения результатов
if [ -d "${PREFIX}" ]; then
	rm -rfv "${PREFIX}/*"
else
	mkdir "${PREFIX}"
fi

echo 'Удаление дубликатов для образца '$1 > "${LOGFILE}"

if [ "$(docker ps -aq -f status=exited -f name=${CONTAINER})" ]; then
	docker rm $CONTAINER | tee -a "${LOGFILE}"
fi

VOLUME=$(printf %q "$SAMPLEPATH")
CMD="docker run --name ${CONTAINER} \
-v ${VOLUME}:/data broadinstitute/gatk:latest \
gatk MarkDuplicates --REMOVE_DUPLICATES \
-I /data/sortbam/${1}.${ALIGNER}.sorted.bam \
-O /data/${CONTAINER}/${1}.${ALIGNER}.sorted.rd.bam \
-M /data/${CONTAINER}/${1}.${CONTAINER}.metrics \
--TMP_DIR /data/${CONTAINER}"

echo $CMD>>"${LOGFILE}"
bash -c "$CMD" 1>"${OUTFILE}" 2>"${ERRFILE}"

END=$(date +%s)
RUNTIME=$((END-START))
eval 'echo $(date -ud "@${RUNTIME}" +"Выполнение заняло %H часов \
%M минут %S секунд")' | tee -a "${LOGFILE}"

