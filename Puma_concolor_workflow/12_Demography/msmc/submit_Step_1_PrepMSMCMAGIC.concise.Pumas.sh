#! /bin/bash

#$ -l h_rt=4:00:00,h_data=1G
#$ -N SUBStep1MSMC
#$ -o /u/home/d/dechavez/project-rwayne/bottleneck/log/SUBStep1MSMC.our
#$ -e /u/home/d/dechavez/project-rwayne/bottleneck/log/SUBStep1MSMC.err
#$ -m abe
#$ -M dechavezv

SCRIPT_DIR=/u/home/d/dechavez/project-rwayne/2nd.paper/4-Demography/msmc
QSUB=/u/systems/UGE8.6.4/bin/lx-amd64/qsub
Scaff=/u/home/d/dechavez/project-rwayne/bottleneck/References/Puma/Scaff.Puma.Gret100kb.txt

cd /u/home/d/dechavez/project-rwayne/bottleneck/VCF/Puma/Indiv/onlyPass

for line in $(cat ${Scaff}); do (echo $line && \
${QSUB} -N GetOnlyPassVCF $SCRIPT_DIR/Step_1_PrepMSMCMAGIC.concise.Puma.sh ${line});done
