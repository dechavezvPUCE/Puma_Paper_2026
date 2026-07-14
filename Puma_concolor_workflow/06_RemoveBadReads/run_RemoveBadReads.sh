#! /bin/bash

#SBATCH -N 1  # number of nodes
#SBATCH -n 1  # number of "tasks" (default: allocates 1 core per task)
#SBATCH -p htc # partition
#SBATCH -q public
#SBATCH -t 0-04:00   # time in d-hh:mm:ss
#SBATCH -o /data/CEM/bottleneck/dechave4/Puma/log/RemoveBadReads.%j.out # file to save job's STDOUT (%j = JobId)
#SBATCH -e /data/CEM/bottleneck/dechave4/Puma/log/RemoveBadReads.%j.err # file to save job's STDERR (%j = JobId)
#SBATCH --mail-type=ALL # Send an e-mail when a job starts, stops, or fails
#SBATCH --mail-user=dechave4@asu.edu # Mail-to address
#SBATCH --export=NONE   # Purge the job-submitting shell environment
#SBATCH --mem=25000

# USAGE: qsub ./run_FastqToSam.sh [dir] [read_1] [read_2] [outfile] [RG] [sample] [library] [flowcell]$

### #SBATCH -p publicgpu # partition
### #SBATCH -q wildfire     # QOS

module load samtools-1.13-gcc-11.2.0

PICARD=/data/CEM/bottleneck/programs/picard-tools/current/picard.jar
mkdir -p /data/CEM/bottleneck/dechave4/Puma/temp/${1%.*}
TEMP_DIR=/data/CEM/bottleneck/dechave4/Puma/temp/${1%.*}
BAM_DIR=/data/CEM/bottleneck/dechave4/Puma/Bams

IN_DIR=/data/CEM/bottleneck/dechave4/Puma/data/Bams
OUT_DIR=/data/CEM/bottleneck/dechave4/Puma/data/Bams

samtools view -hb -f 2 -F 256 -q 30 ${IN_DIR}/${1} | samtools view -hb -F 1024 > ${OUT_DIR}/${1%.bam}_Filtered.bam

java -jar -Xmx24g -Djava.io.tmpdir=${TEMP} ${PICARD} BuildBamIndex \
VALIDATION_STRINGENCY=LENIENT TMP_DIR=/data/CEM/bottleneck/dechave4/Puma/temp \
I=${OUT_DIR}/${1%.bam}_Filtered.bam
