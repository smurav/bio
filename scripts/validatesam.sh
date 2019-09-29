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
SAMPLEPATH=$(dirname "$SCRIPTPATH")/samples
PREFIX=$SAMPLEPATH/$1/$CONTAINER
OUTFILE=$PREFIX/$1.$CONTAINER.stdout
ERRFILE=$PREFIX/$1.$CONTAINER.stderr
LOGFILE=$PREFIX/$1.$CONTAINER.log

# Каталог для сохранения результатов
if [ -d "${PREFIX}" ]; then
	rm -rfv "${PREFIX}/*"
else
	mkdir "${PREFIX}"
fi

echo 'Проверка выравнивания для образца '$1 > "${LOGFILE}"

if [ "$(docker ps -aq -f status=exited -f name=${CONTAINER})" ]; then
	docker rm $CONTAINER | tee -a "${LOGFILE}"
fi

VOLUME=$(printf %q "$SAMPLEPATH")
CMD="docker run --name ${CONTAINER} \
-v ${VOLUME}:/data broadinstitute/gatk:latest \
gatk ValidateSamFile \
-R /data/GCA_000001405.15_GRCh38_full_analysis_set.fna \
-I /data/${1}/sortbam_${ALIGNER}/${1}.${ALIGNER}.sorted.bam \
-M SUMMARY"

echo $CMD>>"${LOGFILE}"
bash -c "$CMD" 1>"${OUTFILE}" 2>"${ERRFILE}"

END=$(date +%s)
RUNTIME=$((END-START))
eval 'echo $(date -ud "@${RUNTIME}" +"Выполнение заняло %H часов \
%M минут %S секунд")' | tee -a "${LOGFILE}"

