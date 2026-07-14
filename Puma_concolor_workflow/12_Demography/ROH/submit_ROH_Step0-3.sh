#! /bin/bash

#SBATCH -N 1  # number of nodes
#SBATCH -n 1  # number of tasks (default: allocates 1 core per task)
#SBATCH -t 0-04:00:00   # time in d-hh:mm:ss
#SBATCH -p htc
#SBATCH -o /data/CEM/bottleneck/dechave4/Puma/log/subStep0_3.%j.out # file to save job's STDOUT (%j = JobId)
#SBATCH -e /data/CEM/bottleneck/dechave4/Puma/log/subStep0_3.%j.err # file to save job's STDERR (%j = JobId)
#SBATCH --mail-type=ALL # Send an e-mail when a job starts, stops, or fails
#SBATCH --mail-user=dechave4@asu.edu # Mail-to address
#SBATCH --export=NONE   # Purge the job-submitting shell environment
#SBATCH --mem-per-cpu=1000

#general
#usage `sbatch submit_ROH_Step0-3.sh [SpsName] [Name1stScaff] [lineOfParam] [NameScaffFile]
#Example
#cd /data/CEM/bottleneck/dechave4/bottleneck/scripts/08_HaplotypeCaller/Scaffolds
#export SCRIPT=/data/CEM/bottleneck/dechave4/Puma/scripts/12_Demography/ROH/submit_ROH_Step0-3.sh
#sbatch ${SCRIPT} UCLA-Puma $(head -n1 *UCLA-Puma*) 10 $(ls *UCLA-Puma*)
## sbatch ${SCRIPT} AddNaso $(head -n1 *AddNaso*) 10 $(ls *AddNaso*)

#Example to run as loop
#List is a list of sps; taken from Bams directory
##cd /data/CEM/bottleneck/dechave4/bottleneck/scripts/08_HaplotypeCaller/Scaffolds
#export SCRIPT=/data/CEM/bottleneck/dechave4/bottleneck/scripts/12_Demography/ROH/submit_ROH_Step0-3.sh
#for line in $(cat List.Bams.txt); do (sbatch ${SCRIPT} ${line} $(head -n1 *${line}*) 10 $(ls *${line}*)) ;done

# [SpsName] The name of your sps
export Sps=${1%/}

# [Name1stScaff] Put the name of the 1st scaffold in the list ${Scaff}
export FirstScaff=$2 #Example ... FirstScaff=NC_056680.1

# [lineOfParam] You will have 30 different paramters settings to chose from. Specify the line you want to chose
export ROHparam=$3

# Change the following paths with your own
export NameScaff=$4

export SCRIPT_DIR=/data/CEM/bottleneck/dechave4/Puma/scripts/12_Demography/ROH
export Direc=/data/CEM/bottleneck/dechave4/Puma/data/VCF/Puma/Combined/${Sps}/Trimmed
export Scaff=/data/CEM/bottleneck/dechave4/bottleneck/scripts/08_HaplotypeCaller/Scaffolds/$NameScaff
export DirPlink=/data/CEM/bottleneck/dechave4/Puma/data/VCF/Puma/Combined/${Sps}/Trimmed/Plink

echo '****************** Running Step 0 getOnlyPassSites ******************'
cd ${Direc}

#Run a job separtly for each VCF file
#for file in *Annot_Mask_Filter.vcf.gz
#	do sbatch ${SCRIPT_DIR}/Step0_getOnlyPass.vcf.sh ${file} ${Direc}
#done
echo '****************** Done Running Step 0 getOnlyPassSites ****************'

#sleep 40m

echo '****************** Running Step 1 ******************'
cd onlyPass
#Provide a list of Scaffolds

#for i in $(cat ${Scaff})
#	do ( echo $i && for file in *${i}*Annot_Mask_Filter_passingSNPs.vcf.gz
#		do sbatch ${SCRIPT_DIR}/Step1_ROH_VCFtoPLINK.sh ${i} ${Direc} ${file}
#		done)
#done


echo '****************** DONE Running Step 1 ******************'

#sleep 120m

echo '****************** Running Step 2 ******************'

# a= --homozyg-snp <min SNP count>
# b= --homozyg-density <max inverse density (kb/SNP)>
# c= --homozyg-gap <max internal gap kb length>
# d= --homozyg-window-snp <scanning window size>
# e= --homozyg-window-het <max hets in scanning window hit>
# f= --homozyg-window-missing <max missing calls in scanning window hit>
# g= --homozyg-window-threshold <min scanning window hit rate>

##For making temp.txt
#for a in 50 100 200; \
#do for b in 50 100; \
#do for c in 1000 2000 5000; \
#do for d in 50 100 200; \
#do for e in 1 2 3 4 5 10 20; \
#do for f in 1 2 3 4 5 10 20; \
#do for g in .02 .05 .1; \
#do echo $a $b $c $d $e $f $g >> ${DirPlink}/plinkInputFiles/temp.txt ; done; done; done; done; done; done; done

#Use the following line to test a wider range of parameters
cp /data/CEM/bottleneck/dechave4/bottleneck/VCF/temp.V2.txt ${DirPlink}/plinkInputFiles
#Note you have to change the loop below to temp.V2.txt

cd ${DirPlink}/plinkInputFiles


#for num in {1..1}; do (echo -e 'ParameterLine='$num'' && \
#for i in $(cat ${Scaff})
#	do ( echo $i && for file in *${i}*.gz.HQsites.Only.rmDotGenotypes.rmBadVars.Plink.map
#		do (echo ${file} && sbatch ${SCRIPT_DIR}/Step2_run_PLINK_plot.sh ${i} $(head -n $num temp.V2.txt | tail -n 1) ${DirPlink} ${Sps} ${FirstScaff} ${file%.map})
#		done)
#done)
#done



echo '******************** Done running Step2 **************************'

#sleep 4h

echo '******************** Running Step3 **************************'

for num in {1..1}; do (echo -e 'ParameterLine='$num'' && \
cd ${DirPlink}/plinkInputFiles && \
cd ${DirPlink}/plinkOutputFiles/plinkroh_$(head -n $num temp.V2.txt | tail -n1 | perl -pe 's/\s+/_/g' | perl -pe 's/(\.\d+)_/\1/g')/ && \
for file in *chr${FirstScaff}*.rmDotGenotypes.rmBadVars.Plink.out.hom
	do ( echo ${file} && sbatch ${SCRIPT_DIR}/Step3_JoinPlinkRunPlot.sh ${Sps} $(head -n $num ${DirPlink}/plinkInputFiles/temp.V2.txt | tail -n 1) ${DirPlink} ${Sps} ${FirstScaff} ${file} )
done)
done


echo '******************** Done running Step3 **************************'
