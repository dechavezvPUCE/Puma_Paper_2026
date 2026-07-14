#! /bin/bash

SCRIPT_DIR=/data/CEM/bottleneck/dechave4/Puma/scripts/06_RemoveBadReads

cd /data/CEM/bottleneck/dechave4/Puma/data/Bams

file=<Aligned.And.MarkDup.bam>
sbatch $SCRIPT_DIR/run_RemoveBadReads.sh ${file}
