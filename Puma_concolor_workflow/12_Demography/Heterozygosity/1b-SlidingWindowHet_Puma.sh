#! /bin/bash

#SBATCH -N 1  # number of nodes
#SBATCH -n 1  # number of tasks (default: allocates 1 core per task)
#SBATCH -t 0-04:00   # time in d-hh:mm:ss
#SBATCH -p public       # partition
#SBATCH -q public	# QOS
#SBATCH -o /data/CEM/bottleneck/dechave4/bottleneck/puma/log/winHet.Puma.%j.out # file to save job's STDOUT (%j = JobId)
#SBATCH -e /data/CEM/bottleneck/dechave4/bottleneck/puma/log/winHet.Puma.%j.err # file to save job's STDERR (%j = JobId)
#SBATCH --mail-type=ALL # Send an e-mail when a job starts, stops, or fails
#SBATCH --mail-user=dechave4@asu.edu # Mail-to address
#SBATCH --export=NONE   # Purge the job-submitting shell environment
#SBATCH --mem-per-cpu=5000

#module load python/2.7.11
module load mamba
source activate WinHet

i=$1

export pythonPath=/data/CEM/bottleneck/dechave4/programs/anaconda2/bin
export Scaffolds=/data/CEM/bottleneck/dechave4/Puma/scripts/12_Demography/Heterozygosity/WindowHet/List.Chr.Puma-UCLA.autosomes.txt
export direc=/data/CEM/bottleneck/dechave4/Puma/data/VCF/Puma/Indv/UCLA-Puma/Trimmed
export SCRIPT=/data/CEM/bottleneck/dechave4/Puma/scripts/12_Demography/Heterozygosity/WindowHet/SlidingWindowHet.Puma.py

cd ${direc}

#for i in $(cat ${Scaffolds})
#	do ( python ${SCRIPT} Ili_${i}_TrimAlt_Annot_Mask_Filter.vcf.gz 100000 100000 ${i})
#done

python ${SCRIPT} BR338_${i}_TrimAlt_Annot_Mask_Filter.vcf.gz 100000 100000 ${i}

source deactivate
