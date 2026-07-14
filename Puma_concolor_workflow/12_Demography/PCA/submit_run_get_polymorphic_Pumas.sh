#! /bin/bash

#$ -l highp,h_rt=4:00:00,h_data=1G
#$ -N subSNPonly
#$ -o /u/scratch/d/dechavez/Puma/log/reportsfilter.out
#$ -e /u/scratch/d/dechavez/Puma/log/reportsfilter.err
#$ -m abe
#$ -M dechavezv

SCRIPT_DIR=/u/home/d/dechavez/project-rwayne/2nd.paper/4-Demography/PCA
QSUB=/u/systems/UGE8.6.4/bin/lx-amd64/qsub

cd /u/scratch/d/dechavez/Puma/VCF/Puma/UCLA-Puma/Combined

for i in {07..20}
	do ${QSUB} -N OnlyPassVCF $SCRIPT_DIR/run_get_polymorphic_Pumas.sh ${i}
done


#for line in $(cat Scaff.Puma.Gret100kb.txt)
#	do (echo $line && \
#	${QSUB} -N OnlyPassVCF $SCRIPT_DIR/run_get_polymorphic_Pumas.sh ${line})
#done

