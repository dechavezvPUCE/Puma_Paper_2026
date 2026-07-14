#! /bin/bash

#SBATCH -N 1  # number of nodes
#SBATCH -n 1  # number of tasks (default: allocates 1 core per task)
#SBATCH -t 0-64:00:00   # time in d-hh:mm:ss
#SBATCH -p general
#SBATCH -q public
#SBATCH -o /data/CEM/bottleneck/dechave4/Puma/log/ROHstep2.%j.out # file to save job's STDOUT (%j = JobId)
#SBATCH -e /data/CEM/bottleneck/dechave4/Puma/log/ROHstep2.%j.err # file to save job's STDERR (%j = JobId)
#SBATCH --mail-type=ALL # Send an e-mail when a job starts, stops, or fails
#SBATCH --mail-user=dechave4@asu.edu # Mail-to address
#SBATCH --export=NONE   # Purge the job-submitting shell environment
#SBATCH --mem-per-cpu=25000

########SBATCH --array=23-41:1

#### #SBATCH -p general    # partition

#module load python/2.7.11
module load vcftools-0.1.14-gcc-11.2.0
module load plink/1.90
#/packages/apps/spack/21/opt/spack/linux-rocky8-zen3/gcc-12.1.0/r-4.4.0-4yi4nm4foi7jsbczjxvv77uq7adnzb67/bin/

# vcftools LROH requires >1 individual
# plink doesn't

wd=$9

cd ${wd}/plinkInputFiles

plinkoutdir=${wd}/plinkOutputFiles

# need to get chr name from file
i=$1

FILE=${12}
OUTDIR=${plinkoutdir}/plinkroh_${2}_${3}_${4}_${5}_${6}_${7}_${8}

mkdir -p ${OUTDIR}

plink --keep-allele-order --file ${FILE} \
--homozyg \
--allow-extra-chr \
--homozyg-kb 100 \
--homozyg-snp ${2} \
--homozyg-density ${3} \
--homozyg-gap ${4} \
--homozyg-window-snp ${5} \
--homozyg-window-het ${6} \
--homozyg-window-missing ${7} \
--homozyg-window-threshold ${8} \
--memory 14000 \
--out ${OUTDIR}/${FILE}.out
