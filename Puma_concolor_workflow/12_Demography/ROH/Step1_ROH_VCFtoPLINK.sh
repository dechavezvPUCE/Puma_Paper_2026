#! /bin/bash

#SBATCH -N 1  # number of nodes
#SBATCH -n 1  # number of tasks (default: allocates 1 core per task)
#SBATCH -t 0-04:00:00   # time in d-hh:mm:ss
#SBATCH -o /data/CEM/bottleneck/dechave4/Puma/log/ROH.%j.out # file to save job's STDOUT (%j = JobId)
#SBATCH -e /data/CEM/bottleneck/dechave4/Puma/log/ROH.%j.err # file to save job's STDERR (%j = JobId)
#SBATCH --mail-type=ALL # Send an e-mail when a job starts, stops, or fails
#SBATCH --mail-user=dechave4@asu.edu # Mail-to address
#SBATCH --export=NONE   # Purge the job-submitting shell environment
#SBATCH --mem-per-cpu=10000

#general

module load vcftools-0.1.14-gcc-11.2.0
module load plink/1.90

# vcftools LROH requires >1 individual
# plink doesn't

# need to get chr name from file
i=$1
wd=$2/Plink
vcf=$3

# convert to ped/map format. note that you lose chromosome info - that's a pain.
plinkindir=$wd/plinkInputFiles
mkdir -p $plinkindir

vcftools --gzvcf $vcf --plink --chr ${i} --out $plinkindir/${vcf%_TrimAlt_Annot_Mask_Filter.vcf.gz}.HQsites.Only.rmDotGenotypes.rmBadVars.Plink
#vcftools --gzvcf $vcf --plink --chr chr$i --out $plinkindir/${Sample%.txt}.${i}.HQsites.Only.rmDotGenotypes.rmBadVars.Plink
