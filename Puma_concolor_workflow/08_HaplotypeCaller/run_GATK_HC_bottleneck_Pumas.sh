#! /bin/bash

#SBATCH --job-name=PumaGVCFbyChr
#SBATCH -N 1  # number of nodes
#SBATCH -n 1  # number of tasks (default: allocates 1 core per task)
#SBATCH -t 0-30:00   # time in d-hh:mm:ss
#SBATCH -p public # partition
#SBATCH -q public
#SBATCH -o /data/CEM/bottleneck/dechave4/Puma/log/Puma.%j.out # file to save job's STDOUT (%j = JobId)
#SBATCH -e /data/CEM/bottleneck/dechave4/Puma/log/Puma.%j.err # file to save job's STDERR (%j = JobId)
#SBATCH --mail-type=ALL # Send an e-mail when a job starts, stops, or fails
#SBATCH --mail-user=dechave4@asu.edu # Mail-to address
#SBATCH --export=NONE   # Purge the job-submitting shell environment
#SBATCH --mem=22000

cd /data/CEM/bottleneck/dechave4/Puma/data/Bams

module load java/latest
export GATK=/data/CEM/bottleneck/programs/GenomeAnalysisTK-3.7-0-gcfedb67/GenomeAnalysisTK.jar
export REFERENCE=/data/CEM/bottleneck/dechave4/Puma/reference/UCSC/GCF_003327715.1_PumCon1.0_genomic.fa
export BAM=Verus.bam_Aligned.Puma-UCSC.MarkDup_Filtered.bam
export ID=${BAM%.bam_Aligned.Puma-UCSC.MarkDup_Filtered.bam}
java -jar -Xmx21g ${GATK} \
-T HaplotypeCaller \
-R ${REFERENCE} \
-ERC BP_RESOLUTION \
-mbq 20 \
-out_mode EMIT_ALL_SITES \
-L NW_020340092.1 \
-I ${BAM} \
-o /data/CEM/bottleneck/dechave4/Puma/data/gVCF/2024/${ID}_chrNW_020340092.1.g.vcf.gz
