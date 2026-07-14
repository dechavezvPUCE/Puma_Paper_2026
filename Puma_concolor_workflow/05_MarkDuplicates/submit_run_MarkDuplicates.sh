#! /bin/bash

SCRIPTDIR=/data/CEM/bottleneck/dechave4/Puma/scripts/05_MarkDuplicates
DIRECT=/data/CEM/bottleneck/dechave4/Puma/data/Bams

cd ${DIRECT}


file=<AlignedFile.bam>
sbatch $SCRIPTDIR/run_MarkDuplicates.sh $file ${file%.bam}.MarkDup.bam
