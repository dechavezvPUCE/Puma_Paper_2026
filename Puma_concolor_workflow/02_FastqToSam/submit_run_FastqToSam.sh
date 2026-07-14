#! /bin/bash

#usage `sbatch script [dir] [read_1] [read_2] [outfile] [RG] [sample] [library] [flowcell] [seq center]`

SCRIPT=/data/CEM/bottleneck/dechave4/Puma/scripts/02_FastqToSam/run_FastqToSam.sh

DIR=/data/CEM/bottleneck/dechave4/Puma/data/rawseq/

sbatch ${SCRIPT} ${DIR} BANK_1.fastq.gz BANK_2.fastq.gz Verus.bam Verus1a Verus Lib1 H5THTDSXY Macrogen
