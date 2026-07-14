#!/bin/bash

#SBATCH --job-name=Delet
#SBATCH --cpus-per-task=1
#SBATCH --time=14:00:00
#SBATCH -p public
#SBATCH -q public
#SBATCH --mail-type=all
#SBATCH --mail-user=dechavez@ucla.edu
#SBATCH --output=/data/CEM/bottleneck/dechave4/Puma/log/Delet.out
#SBATCH --error=/data/CEM/bottleneck/dechave4/Puma/log/Delet.err
#SBATCH --mem=8000

echo '***************** Input Variables ********************************'
#module load anaconda2/5.2.0

date=$(date "+%Y-%m-%d")

Sps=UCSC

SCRIPT=/data/CEM/bottleneck/dechave4/Rails/scripts/12_Demography/DeltVariation/getAlleleGenotCounts.py
OUTDIR=/data/CEM/bottleneck/dechave4/Puma/data/VCF/Puma/Combined/${Sps}/Trimmed/Delet
VCFDIR=/data/CEM/bottleneck/dechave4/Puma/data/VCF/Puma/Combined/${Sps}/Trimmed
Mutt=$1 # list of mutations

mkdir -p ${OUTDIR}

LOG=${OUTDIR}/countSitesPerIndividual_${date}.log

IDX=$2 #Scaff

VCF=JOINT_${IDX}_TrimAlt_Annot_Mask_Filter.vcf.snpEff

if [ $Mutt == 'LOF' ]; then
    $Mutt='start_lost\|stop_gained\|splice_acceptor_variant\|splice_donor_variant'
fi

echo '*****************	Done Inputing Variables	********************************'

echo '***************** Subset VCF for mutations Type ********************************'
cd ${OUTDIR}
zcat ${VCFDIR}/${VCF}.vcf.gz | grep '#' > ${VCF}.${Mutt}.vcf
zcat ${VCFDIR}/${VCF}.vcf.gz | grep ${Mutt} >> ${VCF}.${Mutt}.vcf

#compress
/data/CEM/bottleneck/programs/tabix-0.2.6/bgzip ${VCF}.${Mutt}.vcf
/data/CEM/bottleneck/programs/tabix-0.2.6//tabix -p vcf ${VCF}.${Mutt}.vcf.gz
echo '***************** DONE Subsetting VCF for mutations Type ********************************'

echo '***************** Get alles and Genotype counts ********************************'
# first check the overall vcf.gz file
/data/CEM/bottleneck/dechave4/programs/anaconda2/bin/python ${SCRIPT} --vcf ${VCF}.${Mutt}.vcf.gz --outfile ${Sps}_${IDX}_sites_summary_${Mutt}.txt --filter ".,PASS"
echo '***************** Done Getting and Genotype counts ********************************'
