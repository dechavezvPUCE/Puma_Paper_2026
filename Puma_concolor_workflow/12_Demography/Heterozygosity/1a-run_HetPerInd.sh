#! /bin/bash

#SBATCH -N 1  # number of nodes
#SBATCH -n 1  # number of tasks (default: allocates 1 core per task)
#SBATCH -t 0-08:00:00   # time in d-hh:mm:ss
#SBATCH -o /data/CEM/bottleneck/dechave4/bottleneck/log/HetTotal.seq.%j.out # file to save job's STDOUT (%j = JobId)
#SBATCH -e /data/CEM/bottleneck/dechave4/bottleneck/log/HetTotal.seq.%j.err # file to save job's STDERR (%j = JobId)
#SBATCH --mail-type=ALL # Send an e-mail when a job starts, stops, or fails
#SBATCH --mail-user=dechave4@asu.edu # Mail-to address
#SBATCH --export=NONE   # Purge the job-submitting shell environment
#SBATCH --mem-per-cpu=2000

# Usage: sbatch run_HetPerInd.sh

SCRIPTDIR=/data/CEM/bottleneck/dechave4/bottleneck/scripts/12_Demography/Heterozygosity/TotalHete

#Direc=/data/CEM/bottleneck/dechave4/bottleneck/VCF/$1/Trimmed
Direc=/data/CEM/bottleneck/dechave4/Puma/data/VCF/Puma/Combined/$1/Trimmed
#Sacaffolds=/data/CEM/bottleneck/Scaffolds/Armadillo/Head.Scaf.txt

cd ${Direc}

#for file in *Mask_Filter.vcf.gz
#	do /data/CEM/bottleneck/dechave4/programs/anaconda2/bin/python ${SCRIPTDIR}/HetPerInd.py $file
#done
file=$2
/data/CEM/bottleneck/dechave4/programs/anaconda2/bin/python ${SCRIPTDIR}/HetPerInd.py $2



#for file in *Mask_Filter.vcf.gz
#	do ( echo $file && if [ -s ${file}_HetPerInd.txt ]
#	then :
#	else python ${SCRIPTDIR}/HetPerInd.py $file
#	fi)
#done

#python ${SCRIPTDIR}/HetPerInd.py HydHyd_chrCM027416.1_TrimAlt_Annot_Mask_Filter.vcf.gz

#for i in $(cat ${Sacaffolds})
#do python ${SCRIPTDIR}/HetPerInd.py DasNov_chr${i}_TrimAlt_Annot_Mask_Filter.vcf.gz
#done
