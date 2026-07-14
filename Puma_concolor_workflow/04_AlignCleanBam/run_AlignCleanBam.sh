#! /bin/bash

#SBATCH --job-name=PumaAling
#SBATCH -N 1  # number of nodes
#SBATCH -n 7  # number of "tasks" (default: allocates 1 core per task)
#SBATCH -t 0-59:00:00  # time in d-hh:mm:ss
#SBATCH -p public # partition
#SBATCH -q public	# QOS
#SBATCH -o /data/CEM/bottleneck/dechave4/Puma/log/AlignPuma.%j.out # file to save job's STDOUT (%j = JobId)
#SBATCH -e /data/CEM/bottleneck/dechave4/Puma/log/AlignPuma.%j.err # file to save job's STDERR (%j = JobId)
#SBATCH --mail-type=ALL # Send an e-mail when a job starts, stops, or fails
#SBATCH --mail-user=dechave4@asu.edu # Mail-to address
#SBATCH --export=NONE   # Purge the job-submitting shell environment
#SBATCH --mem=21000
# USAGE: qsub ./run_FastqToSam.sh [dir] [read_1] [read_2] [outfile] [RG] [sample] [library] [flowcell]$

#load modules
module load bwa-0.7.17-gcc-12.1.0

java=/data/CEM/bottleneck/dechave4/programs/jre1.8.0_411/bin/java
PICARD=/data/CEM/bottleneck/programs/picard-tools/current/picard.jar
BAM_DIR=/data/CEM/bottleneck/dechave4/Puma/data/Bams
BAM_OUT=/data/CEM/bottleneck/dechave4/Puma/data/Bams

FILENAME=${1}

mkdir -p /data/CEM/bottleneck/dechave4/bottleneck/temp/${1%.*}
TEMP_DIR=/data/CEM/bottleneck/dechave4/bottleneck/temp/${1%.*}

#What Species to map with?

#Sps=Puma-UCLA
Sps=Puma-UCSC
REFERENCE=/data/CEM/bottleneck/dechave4/Puma/reference/UCSC/GCF_003327715.1_PumCon1.0_genomic.fa
#REFERENCE=/data/CEM/bottleneck/dechave4/Puma/reference/UCLA.Sonoma/GCA_028749985.3_UCLA_EditNames.fa

#Sps=Cat
#REFERENCE=/data/CEM/bottleneck/reference/cat/GCF_000181335.3_Felis_catus_9.0_genomic.fa

cd ${BAM_OUT}/${Sps}

set -o pipefail

${java} -Xmx20G -jar -Djava.io.tmpdir=${TEMP_DIR} \
${PICARD} SamToFastq \
I=${BAM_DIR}/${FILENAME}_MarkIlluminaAdapters.bam \
FASTQ=/dev/stdout \
CLIPPING_ATTRIBUTE=XT CLIPPING_ACTION=2 INTERLEAVE=true NON_PF=true \
TMP_DIR=${TEMP_DIR} 2>>./"Process_"${FILENAME}"_SamToFastq."${Sps}".txt" | \
bwa mem -M -t 7 -p ${REFERENCE} /dev/stdin 2>>./"Process_"${FILENAME}"_BwaMem."${Sps}".txt" | \
java -Xmx6G -jar -Djava.io.tmpdir=${TEMP_DIR} \
${PICARD} MergeBamAlignment \
ALIGNED_BAM=/dev/stdin \
UNMAPPED_BAM=${BAM_DIR}/${FILENAME} \
OUTPUT=${BAM_OUT}/${FILENAME}_Aligned.${Sps}.bam \
R=${REFERENCE} CREATE_INDEX=true \
ADD_MATE_CIGAR=true CLIP_ADAPTERS=false CLIP_OVERLAPPING_READS=true \
INCLUDE_SECONDARY_ALIGNMENTS=true MAX_INSERTIONS_OR_DELETIONS=-1 \
PRIMARY_ALIGNMENT_STRATEGY=MostDistant ATTRIBUTES_TO_RETAIN=XS \
TMP_DIR=${TEMP_DIR} 2>>./"Process_"${FILENAME}"_MergeBam."${FILENAME}"."${Sps}".txt"
