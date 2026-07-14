#! /bin/bash

#SBATCH -N 1  # number of nodes
#SBATCH -n 1  # number of tasks (default: allocates 1 core per task)
#SBATCH -t 0-04:00:00   # time in d-hh:mm:ss
#SBATCH -o /data/CEM/bottleneck/dechave4/Puma/log/ROHstep3.%j.out # file to save job's STDOUT (%j = JobId)
#SBATCH -e /data/CEM/bottleneck/dechave4/Puma/log/ROHstep3.%j.err # file to save job's STDERR (%j = JobId)
#SBATCH --mail-type=ALL # Send an e-mail when a job starts, stops, or fails
#SBATCH --mail-user=dechave4@asu.edu # Mail-to address
#SBATCH --export=NONE   # Purge the job-submitting shell environment
#SBATCH --mem-per-cpu=9000

#publicgpu

Sample=${1}
wd=${9}
plinkoutdir=${wd}/plinkOutputFiles
OUTDIR=${plinkoutdir}/plinkroh_${2}_${3}_${4}_${5}_${6}_${7}_${8}
pdfName=${2}_${3}_${4}_${5}_${6}_${7}_${8}
R=/packages/apps/spack/21/opt/spack/linux-rocky8-zen3/gcc-12.1.0/r-4.4.0-4yi4nm4foi7jsbczjxvv77uq7adnzb67/bin

cd ${OUTDIR}
rm *summary

mkdir -p catted

#testing_povide name of sample
export Sps=${10}
export First=${11}
export Firsthom=${12}

#rm catted/*.hom

head -n1 ${Firsthom}  > catted/${Sps}.catted.hom
cat *.hom |  grep -v "FID"  >>  catted/${Sps}.catted.hom

cd catted/

rm *.pdf

SCRIPT=/data/CEM/bottleneck/dechave4/Puma/scripts/12_Demography/ROH/plot_ROHStep2.R
pwd
ls ${Sps}.catted.hom
echo ${Sample}
${R}/Rscript ${SCRIPT} ${Sps}.catted.hom ${Sample} ${pdfName}

#sleep 7m

mv *.pdf /data/CEM/bottleneck/dechave4/bottleneck/ROH/pdfs/

## R CMD BATCH --no-save --no-restore '--args 'plinkroh_${2}_${3}_${4}_${5}_${6}_${7}_${8}' '${SCRIPT}
