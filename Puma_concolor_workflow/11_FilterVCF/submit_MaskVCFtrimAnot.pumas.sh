#! /bin/bash

export SCRIPTDIR=/data/CEM/bottleneck/dechave4/Puma/scripts/11_FilterVCF
export Direc=/data/CEM/bottleneck/dechave4/Puma/data/VCF/Puma/Indv/UCLA-Puma/Trimmed

cd ${Direc}

for i in BR338*TrimAlt_Annot.vcf.gz; do
	FILENAME=${i}
	sbatch $SCRIPTDIR/Mask_Filter_bottleneck.Pumas.sh ${FILENAME}
done

#sbatch $SCRIPTDIR/Mask_Filter_bottleneck.Pumas.sh JOINT_chrA1_TrimAlt_Annot.vcf.gz
