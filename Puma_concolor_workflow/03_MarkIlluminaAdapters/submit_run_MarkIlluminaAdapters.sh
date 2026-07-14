#! /bin/bash

#usage `sbatch script [file.bam]`

SCRIPTDIR=/data/CEM/bottleneck/dechave4/Puma/scripts/03_MarkIlluminaAdapters

cd /data/CEM/bottleneck/dechave4/Puma/data/Bams

sbatch $SCRIPTDIR/run_MarkIlluminaAdapters.sh Verus.bam
