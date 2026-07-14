#! /bin/bash

#SBATCH --job-name=Step11PumaFilterVCF
#SBATCH -N 1  # number of nodes
#SBATCH -n 1  # number of tasks (default: allocates 1 core per task)
#SBATCH -t 0-14:00   # time in d-hh:mm:ss
#SBATCH -p public	# partition
#SBATCH -q public	# QOS
#SBATCH -o /data/CEM/bottleneck/dechave4/Puma/log/Step11_Pumas.%j.out # file to save job's STDOUT (%j = JobId)
#SBATCH -e /data/CEM/bottleneck/dechave4/Puma/log/Step11_Pumas..%j.err # file to save job's STDERR (%j = JobId)
#SBATCH --mail-type=ALL # Send an e-mail when a job starts, stops, or fails
#SBATCH --mail-user=dechave4@asu.edu # Mail-to address
#SBATCH --export=NONE   # Purge the job-submitting shell environment
#SBATCH --mem-per-cpu=8000

#load modules

export GATK=/data/CEM/bottleneck/programs/GenomeAnalysisTK-3.7-0-gcfedb67/GenomeAnalysisTK.jar
export REFERENCE=/data/CEM/bottleneck/dechave4/Puma/reference/UCLA.Sonoma/GCA_028749985.3_UCLA_EditNames.fa
export tabix=/data/CEM/bottleneck/programs/tabix-0.2.6

cd /data/CEM/bottleneck/dechave4/Puma/data/VCF/Puma/Indv/UCLA-Puma/Trimmed

VCF=${1}

### VariantFiltration
LOG=${VCF%.vcf.gz}_VariantFiltration.log
date "+%Y-%m-%d %T" > ${LOG}

java -jar -Xmx7g $GATK \
-T VariantFiltration \
-R ${REFERENCE} \
-filter "QD < 2.0" -filterName "FAIL_QD" \
-filter "FS > 60.0" -filterName "FAIL_FS" \
-filter "MQ < 40.0" -filterName "FAIL_MQ" \
-filter "MQRankSum < -12.5" -filterName "FAIL_MQRankSum" \
-filter "ReadPosRankSum < -8.0" -filterName "FAIL_ReadPosRankSum" \
-filter "ReadPosRankSum > 8.0" -filterName "FAIL_ReadPosRankSum" \
-filter "SOR > 4.0" -filterName "FAIL_SOR" \
-l ERROR \
-V ${VCF} \
-o ${VCF%.vcf.gz}_Mask.vcf.gz &>> ${LOG}

exitVal=${?}
if [ ${exitVal} -ne 0 ]; then
	echo -e "FAILED SelectVariants" >> ${LOG}
	exit
fi
date "+%Y-%m-%d %T" >> ${LOG}

### Custom filtering

SCRIPT=/data/CEM/bottleneck/dechave4/Puma/scripts/11_FilterVCF/filterVCF_bottleneck.py

/data/CEM/bottleneck/dechave4/programs/anaconda2/bin/python2 ${SCRIPT} ${VCF%.vcf.gz}_Mask.vcf.gz | ${tabix}/bgzip > ${VCF%.vcf.gz}_Mask_Filter.vcf.gz

${tabix}/tabix -p vcf ${VCF%.vcf.gz}_Mask_Filter.vcf.gz
