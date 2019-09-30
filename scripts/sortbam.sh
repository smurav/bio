#!/bin/bash

if [ -z "$1" ]; then
    echo "Укажите идентификатор образца"
    exit -1
fi

ALIGNER=bowtie2
if [ ! -z "$2" ]; then
    ALIGNER=$2
fi

START=$(date +%s)
BASENAME=$(basename -- "$0")
CONTAINER="${BASENAME%.*}"_$ALIGNER
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

echo 'Сортировка BAM для образца '$1 > "${LOGFILE}"

if [ "$(docker ps -aq -f status=exited -f name=${CONTAINER})" ]; then
	docker rm $CONTAINER | tee -a "${LOGFILE}"
fi

VOLUME=$(printf %q "$SAMPLEPATH")
CMD="docker run --name ${CONTAINER} \
-v ${VOLUME}:/data biocontainers/samtools:v1.7.0_cv4 \
samtools sort -@ 7 -l 9 -O bam -T /data/${CONTAINER} \
-o /data/sortbam_${ALIGNER}/${1}.${ALIGNER}.sorted.bam \
/data/sam2bam/${1}.${ALIGNER}.bam"
echo $CMD>>"${LOGFILE}"
bash -c "$CMD" 1>"${OUTFILE}" 2>"${ERRFILE}"

END=$(date +%s)
RUNTIME=$((END-START))
eval 'echo $(date -ud "@${RUNTIME}" +"Выполнение заняло %H часов \
%M минут %S секунд")' | tee -a "${LOGFILE}"
