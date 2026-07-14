#! /bin/bash

#usage `sbatch script [file.bam]`

export SCRIPTDIR=<pathToscriptDirectory>/scripts/04_AlignCleanBam
export Direc=<pathToscriptDataDirectory>/data/Bams

cd ${Direc}


#sbatch $SCRIPTDIR/run_AlignCleanBam.sh Ili.Puma.bam

