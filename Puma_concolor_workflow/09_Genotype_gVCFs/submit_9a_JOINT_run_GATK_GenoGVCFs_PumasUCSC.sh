#! /bin/bash

# Run this script to make and submit job array scripts for each individual.
# Here, the for-loop is over the chromosomes and the array is over the individuals.
# The script is generated and submitted, and then overwritten with each subsequent iteration of the for-loop.

# Runtimes vary according to chromosome length.

# I submitted chromosome separately, in three parts.
# Chromosomes 01-12 were submitted with a 40-hr requested runtime.
# Chromosomes 13-22 were submitted with a 30-hr requested runtime.
# Chromosomes 23-38 were submitted with a 24-hr requested runtime in the 24-hr queue (not highp).

# Runtime is about twice as long if non-intel chips are used!
# Our group has only intel chips so I don't specify the architecture,
# but when I submit to the 24-hr queue I add arch=intel* to the -l line of the script header.

# Sometimes, for whatever reason, jobs would go slowly and run out of time and I just resubmitted
# those failed ones individually as needed.

# I'm not totally sure about the wisdom of using the --dontUseSoftClippedBases option,
# but I know I used it last time, so I kept it here for consistency with the previous fox study.

#284..312
#/data/CEM/bottleneck/dechave4/bottleneck/scripts/08_HaplotypeCaller/Scaffolds/LS02.FastqToSam.bam_Aligned.LatJam.MarkDup_Filtered.ScaffGret1MB.txt
#Missin.Scaff.txt
cd /data/CEM/bottleneck/dechave4/Puma/scripts/09_Genotype_gVCFs/9a_gVCFtoVCF
for i in $(cat /data/CEM/bottleneck/dechave4/Puma/reference/UCSC/Scaff.Puma.Gret100kb.txt);
	do (
	echo "#! /bin/bash"
	echo
	echo "#SBATCH --job-name=PumaGVCFtoVCF"
	echo "#SBATCH -N 1  # number of nodes"
	echo "#SBATCH -n 1  # number of "tasks" (default: allocates 1 core per task)"
	echo "#SBATCH -t 0-64:00   # time in d-hh:mm:ss"
	echo "#SBATCH -p public # partition"
	echo "#SBATCH -q public"
	echo "#SBATCH -o /data/CEM/bottleneck/dechave4/Puma/log/GVCFtoVCF.%j.out # file to save job's STDOUT (%j = JobId)"
	echo "#SBATCH -e /data/CEM/bottleneck/dechave4/Puma/log/GVCFtoVCF.%j.err # file to save job's STDERR (%j = JobId)"
	echo "#SBATCH --mail-type=ALL # Send an e-mail when a job starts, stops, or fails"
	echo "#SBATCH --mail-user=dechave4@asu.edu # Mail-to address"
	echo "#SBATCH --export=NONE   # Purge the job-submitting shell environment"
	echo "#SBATCH --mem=22000"
	echo
	echo "OUT=/data/CEM/bottleneck/dechave4/Puma/data/VCF/Puma/Combined/UCSC"
	echo "cd /data/CEM/bottleneck/dechave4/Puma/data/gVCF/2024"
	echo "Sps=/data/CEM/bottleneck/dechave4/Puma/scripts/09_Genotype_gVCFs/9a_gVCFtoVCF/Sps.txt"
	echo
	echo "module load java/latest"
	echo "export GATK=/data/CEM/bottleneck/programs/GenomeAnalysisTK-3.7-0-gcfedb67/GenomeAnalysisTK.jar"
	echo "export REFERENCE=/data/CEM/bottleneck/dechave4/Puma/reference/UCSC/GCF_003327715.1_PumCon1.0_genomic.fa"
	echo "java -jar -Xmx21g \${GATK} \\"
	echo "-T GenotypeGVCFs \\"
	echo "-R \${REFERENCE} \\"
	echo "-allSites \\"
	echo "-L ${i} \\"
	echo "$(for j in $(cat /data/CEM/bottleneck/dechave4/Puma/scripts/09_Genotype_gVCFs/9a_gVCFtoVCF/Sps.UCSC.txt); do echo "-V ${j}_chr${i}.g.vcf.gz \\"; done)"
	echo "-o \${OUT}/JOINT_${i}.vcf.gz"

	) > "run_GATK_gVCFtoVCF_Combined_Pumas.sh"

	sbatch run_GATK_gVCFtoVCF_Combined_Pumas.sh

done
