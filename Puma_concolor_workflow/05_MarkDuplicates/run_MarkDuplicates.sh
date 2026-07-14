#! /bin/bash

#SBATCH -N 1  # number of nodes
#SBATCH -n 1  # number of "tasks" (default: allocates 1 core per task)
#SBATCH -t 25:00:00   # time in d-hh:mm:ss
#SBATCH -p public # partition
#SBATCH -q public
#SBATCH -o /data/CEM/bottleneck/dechave4/Pumas/log/MarkDup.seq.%j.out # file to save job's STDOUT (%j = JobId)
#SBATCH -e /data/CEM/bottleneck/dechave4/Pumas/log/MarkDup.seq.%j.err # file to save job's STDERR (%j = JobId)
#SBATCH --mail-type=ALL # Send an e-mail when a job starts, stops, or fails
#SBATCH --mail-user=dechave4@asu.edu # Mail-to address
#SBATCH --export=NONE   # Purge the job-submitting shell environment
#SBATCH --mem=10000
# USAGE: qsub ./run_FastqToSam.sh [dir] [read_1] [read_2] [outfile] [RG] [sample] [library] [flowcell]$

### ulimit -a

### #$ -pe shared 4

#highmem

java=/data/CEM/bottleneck/dechave4/programs/jre1.8.0_411/bin/java
PICARD=/data/CEM/bottleneck/programs/picard-tools/current/picard.jar
BAM_DIR=/data/CEM/bottleneck/dechave4/Puma/data/Bams
BAM_OUT=/data/CEM/bottleneck/dechave4/Puma/data/Bams

mkdir -p /data/CEM/bottleneck/dechave4/Pumas/temp/${1%.*}
TEMP_DIR=/data/CEM/bottleneck/dechave4/Pumas/temp/${1%.*}

BAM1=$1
BAM_OUT=$2
## OPT_DIST=$3

${java} -Xmx9G -Djava.io.tmpdir=$TEMP_DIR -jar $PICARD MarkDuplicates \
MAX_RECORDS_IN_RAM=150000 \
MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000 \
INPUT=$BAM_DIR/$BAM1 \
OUTPUT=$BAM_DIR/$BAM_OUT \
METRICS_FILE=$BAM_DIR/${BAM_OUT}_metrics.txt \
OPTICAL_DUPLICATE_PIXEL_DISTANCE=2500 \
CREATE_INDEX=true \
TMP_DIR=$TEMP_DIR
