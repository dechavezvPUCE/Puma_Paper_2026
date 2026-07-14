#! /bin/bash

#SBATCH -N 1  # number of nodes
#SBATCH -n 1  # number of "tasks" (default: allocates 1 core per task)
#SBATCH -p public # partition
#SBATCH -q public	# QOS
#SBATCH -t 0-64:00   # time in d-hh:mm:ss
#SBATCH -o /data/CEM/bottleneck/dechave4/Puma/log/MarkIlAd.seq.Puma.%j.out # file to save job's STDOUT (%j = JobId)
#SBATCH -e /data/CEM/bottleneck/dechave4/Puma/log/MarkIlAd.seq.Puma.%j.err # file to save job's STDERR (%j = JobId)
#SBATCH --mail-type=ALL # Send an e-mail when a job starts, stops, or fails
#SBATCH --mail-user=dechave4@asu.edu # Mail-to address
#SBATCH --export=NONE   # Purge the job-submitting shell environment
#SBATCH --mem=15000


##### #SBATCH -p publicgpu    # partition
#### #SBATCH -q wildfire

# USAGE: qsub ./run_FastqToSam.sh [dir] [read_1] [read_2] [outfile] [RG] [sample] [library] [flowcell] [seq center]

module load java/8u102

mkdir -p /data/CEM/bottleneck/dechave4/Puma/temp/${1%.*}
TEMP_DIR=/data/CEM/bottleneck/dechave4/Puma/temp/${1%.*}

DIR=/data/CEM/bottleneck/dechave4/Puma/data/Bams
PICARD=/data/CEM/bottleneck/programs/picard-tools/current/picard.jar

cd $DIR

FILENAME=$1

java -Xmx14G -jar -Djava.io.tmpdir=$TEMP_DIR \
${PICARD} \
MarkIlluminaAdapters \
I=$DIR/${FILENAME} \
O=$DIR/${FILENAME%_FastqToSam.bam}_MarkIlluminaAdapters.bam \
M=$DIR/${FILENAME%_FastqToSam.bam}_MarkIlluminaAdapters.bam_metrics.txt \
TMP_DIR=$TEMP_DIR
