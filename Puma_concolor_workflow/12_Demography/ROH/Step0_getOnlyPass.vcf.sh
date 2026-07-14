#! /bin/bash

#SBATCH -N 1  # number of nodes
#SBATCH -n 1  # number of tasks (default: allocates 1 core per task)
#SBATCH -p htc
#SBATCH -q public
#SBATCH -t 0-04:00:00   # time in d-hh:mm:ss
#SBATCH -o /data/CEM/bottleneck/dechave4/Puma/log/RunOnlyPass.%j.out # file to save job's STDOUT (%j = JobId)
#SBATCH -e /data/CEM/bottleneck/dechave4/Puma/log/RunOnlyPass.%j.err # file to save job's STDERR (%j = JobId)
#SBATCH --mail-type=ALL # Send an e-mail when a job starts, stops, or fails
#SBATCH --mail-user=dechave4@asu.edu # Mail-to address
#SBATCH --export=NONE   # Purge the job-submitting shell environment
#SBATCH --mem-per-cpu=1000

#general

module load tabix-2013-12-16-gcc-12.1.0

VCF=$1
Direc=$2
tabix=/data/CEM/bottleneck/programs/tabix-0.2.6

cd ${Direc}

mkdir -p onlyPass

zcat ${VCF} | \
grep -v "FAIL" | grep -v "WARN" | grep -vE '\./\.' | \
grep -v "AF=0.0;" | grep -v "AF=0.00;" | grep -v "AF=1.0" | grep -vE '\./\.' | \
grep -v "NO_VARIATION" | grep -v "NON_REF" | ${tabix}/bgzip > ${Direc}/onlyPass/${VCF%.vcf.gz}_passingSNPs.vcf.gz

sleep 30s

cd ${Direc}/onlyPass

${tabix}/tabix -p vcf ${VCF%.vcf.gz}_passingSNPs.vcf.gz

echo '************** Done getting sites with Good Quality from chr$i **********'
