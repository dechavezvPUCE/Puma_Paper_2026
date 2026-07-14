#!/bin/bash

Direc=/data/CEM/bottleneck/dechave4/Puma/data/VCF/Puma/Combined/UCSC/Trimmed
Scaff=/data/CEM/bottleneck/dechave4/Puma/data/VCF/Puma/Combined/Trimmed/List.Scaff.PumCon.UCSC.txt
SCRIPT=/data/CEM/bottleneck/dechave4/Puma/scripts/12_Demography/DeltVariation
Sps=JOINT

cd ${Direc}

for Scaf in $(cat ${Scaff})
	do (echo $Scaf && sbatch ${SCRIPT}/run_SubsetVCF_getAlleleGenotCounts.PumaUCSC.sh missense_variant ${Scaf} ${Sps})
done

### Make sure to run not just for missense_variant but also the following:
#synonymous_variant
#missense_variant
#LOF
