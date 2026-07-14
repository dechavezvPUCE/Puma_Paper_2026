#! /bin/bash

#$ -l h_rt=4:00:00,h_data=1G
#$ -N SUBStep2MSMC
#$ -o /u/home/d/dechavez/project-rwayne/bottleneck/log/SUBStep2MSMC.our
#$ -e /u/home/d/dechavez/project-rwayne/bottleneck/log/SUBStep2MSMC.err
#$ -m abe
#$ -M dechavezv

SCRIPT_DIR=/u/home/d/dechavez/project-rwayne/2nd.paper/4-Demography/msmc
QSUB=/u/systems/UGE8.6.4/bin/lx-amd64/qsub
Scaff=/u/home/d/dechavez/project-rwayne/bottleneck/References/Puma/Scaff.Puma.Gret100kb.txt

cd /u/home/d/dechavez/project-rwayne/bottleneck/VCF/Puma/Indiv/06142022/msmcAnalysis/inputFiles

for i in {07..20};
do ${QSUB} -N PumamsmcStep2 ${SCRIPT_DIR}/Step_2_runMSMC.Pumas.sh ${i}
done

#####${QSUB} -N PumamsmcStep2 ${SCRIPT_DIR}/Step_2_runMSMC.Pumas.sh 07_chunk_NW_020337930.1_postMultiHetSep.txt
