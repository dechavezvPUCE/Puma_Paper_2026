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
#/data/CEM/bottleneck/Scaffolds/Armadillo/Head.Scaf.txt
for i in $(cat /data/CEM/bottleneck/dechave4/Puma/scripts/08_HaplotypeCaller/Scaffolds/List.Chr.Puma-UCLA.txt);
	do (
	echo "#! /bin/bash"
	echo
	echo "#SBATCH --job-name=Comb.PumaTrimrAlter"
	echo "#SBATCH -N 1  # number of nodes"
	echo "#SBATCH -n 1  # number of "tasks" (default: allocates 1 core per task)"
	echo "#SBATCH -t 0-23:00   # time in d-hh:mm:ss"
	echo "#SBATCH -p public # partition"
	echo "#SBATCH -q public"
	echo "#SBATCH -o /data/CEM/bottleneck/dechave4/Pumas/log/JointPumasTrimrAlte.Cpmb.%j.out # file to save job's STDOUT (%j = JobId)"
	echo "#SBATCH -e /data/CEM/bottleneck/dechave4/Pumas/log/JointPumasTrimrAlte.Comb.%j.err # file to save job's STDERR (%j = JobId)"
	echo "#SBATCH --mail-type=ALL # Send an e-mail when a job starts, stops, or fails"
	echo "#SBATCH --mail-user=dechave4@asu.edu # Mail-to address"
	echo "#SBATCH --export=NONE   # Purge the job-submitting shell environment"
	echo "#SBATCH --mem=10000"
	echo
	echo "OUT=/data/CEM/bottleneck/dechave4/Puma/data/VCF/Puma/Combined/UCLA-Puma/Trimmed"
	echo "cd /data/CEM/bottleneck/dechave4/Puma/data/VCF/Puma/Combined/UCLA-Puma"
	echo "mkdir -p \${OUT}"
	echo
	echo "module load java/latest"
	echo "export GATK=/data/CEM/bottleneck/programs/GenomeAnalysisTK-3.7-0-gcfedb67/GenomeAnalysisTK.jar"
	echo "export REFERENCE=/data/CEM/bottleneck/dechave4/Puma/reference/UCLA.Sonoma/GCA_028749985.3_UCLA_EditNames.fa"
	echo "export ID=JOINT"
	echo
	echo "java -jar -Xmx9g \${GATK} \\"
        echo "-T SelectVariants \\"
        echo "-R \${REFERENCE} \\"
        echo "-L ${i} \\"
        echo "-trimAlternates \\"
        echo "-V \${ID}_${i}.vcf.gz \\"
        echo "-o \${OUT}/\${ID}_${i}_TrimAlt.vcf.gz"
        echo
	echo "java -jar -Xmx9g \${GATK} \\"
        echo "-T VariantAnnotator \\"
        echo "-R \${REFERENCE} \\"
        echo "-G StandardAnnotation \\"
        echo "-A VariantType \\"
        echo "-A AlleleBalance \\"
        echo "-L ${i} \\"
        echo "-V \${OUT}/\${ID}_${i}_TrimAlt.vcf.gz \\"
        echo "-o \${OUT}/\${ID}_${i}_TrimAlt_Annot.vcf.gz"

	) > "run_GATK_Combined_TrimAlt_AddAnnot_Pumas.sh"

	sbatch run_GATK_Combined_TrimAlt_AddAnnot_Pumas.sh

done
