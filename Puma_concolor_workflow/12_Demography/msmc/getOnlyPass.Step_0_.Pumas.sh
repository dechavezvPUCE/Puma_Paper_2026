#! /bin/bash
#$ -wd /u/home/d/dechavez/project-rwayne/bottleneck/VCF/Puma/Indiv
#$ -l h_rt=4:00:00,h_data=1G,arch=intel*
#$ -N OnlySNPs
#$ -o /u/home/d/dechavez/project-rwayne/bottleneck/log/OnlyPassPuma.out
#$ -e /u/home/d/dechavez/project-rwayne/bottleneck/log/OnlyPassPuma.err
#$ -m abe
#$ -M dechavezv
#$ -t 7-20:1

Direc=/u/home/d/dechavez/project-rwayne/bottleneck/VCF/Puma/Indiv
export tabix=/u/home/d/dechavez/tabix-0.2.6

cd ${Direc}

mkdir -p onlyPass

PREFIX=${1}
Sps=$(printf "%02d" "$SGE_TASK_ID")

zcat ${Sps}_chr${PREFIX}.Puma.TrimAlt_Annot_Mask_Filter.vcf.gz | \
grep -v "FAIL" | grep -v "WARN" | grep -vE '\./\.' | ${tabix}/bgzip -c \
> ${Direc}/onlyPass/${Sps}_chr${PREFIX}.Puma.TrimAlt_Annot_Mask_Filter_passingSNPs.vcf.gz

#sleep 15m

cd ${Direc}/onlyPass

/u/home/d/dechavez/tabix-0.2.6/tabix -p vcf ${Sps}_chr${PREFIX}.Puma.TrimAlt_Annot_Mask_Filter_passingSNPs.vcf.gz

echo '************** Done getting sites with Good Quality from chr$i **********'
