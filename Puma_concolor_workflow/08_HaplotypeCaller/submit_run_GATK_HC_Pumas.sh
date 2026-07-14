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
#/data/CEM/bottleneck/dechave4/Puma/reference/UCSC/Scaff.Puma.Gret100kb.txt
#/data/CEM/bottleneck/dechave4/Puma/scripts/08_HaplotypeCaller/Scaffolds/List.Chr.Puma-UCLA.txt
for i in $(cat /data/CEM/bottleneck/dechave4/Puma/reference/UCSC/Scaff.Puma.Gret100kb.txt);
	do (
	echo "#! /bin/bash"
	echo
	echo "#SBATCH --job-name=PumaGVCFbyChr"
	echo "#SBATCH -N 1  # number of nodes"
	echo "#SBATCH -n 1  # number of "tasks" (default: allocates 1 core per task)"
	echo "#SBATCH -t 0-30:00   # time in d-hh:mm:ss"
	echo "#SBATCH -p public # partition"
	echo "#SBATCH -q public"
	echo "#SBATCH -o /data/CEM/bottleneck/dechave4/Puma/log/Puma.%j.out # file to save job's STDOUT (%j = JobId)"
	echo "#SBATCH -e /data/CEM/bottleneck/dechave4/Puma/log/Puma.%j.err # file to save job's STDERR (%j = JobId)"
	echo "#SBATCH --mail-type=ALL # Send an e-mail when a job starts, stops, or fails"
	echo "#SBATCH --mail-user=dechave4@asu.edu # Mail-to address"
	echo "#SBATCH --export=NONE   # Purge the job-submitting shell environment"
	echo "#SBATCH --mem=22000"
	echo
	echo "cd /data/CEM/bottleneck/dechave4/Puma/data/Bams"
	echo
	echo "module load java/latest"
	echo "export GATK=/data/CEM/bottleneck/programs/GenomeAnalysisTK-3.7-0-gcfedb67/GenomeAnalysisTK.jar"
	echo "export REFERENCE=/data/CEM/bottleneck/dechave4/Puma/reference/UCSC/GCF_003327715.1_PumCon1.0_genomic.fa"
	echo "export BAM=Verus.bam_Aligned.Puma-UCSC.MarkDup_Filtered.bam"
	echo "export ID=\${BAM%.bam_Aligned.Puma-UCSC.MarkDup_Filtered.bam}"
	echo "java -jar -Xmx21g \${GATK} \\"
	echo "-T HaplotypeCaller \\"
	echo "-R \${REFERENCE} \\"
	echo "-ERC BP_RESOLUTION \\"
	echo "-mbq 20 \\"
	echo "-out_mode EMIT_ALL_SITES \\"
	echo "-L ${i} \\"
	echo "-I \${BAM} \\"
	echo "-o /data/CEM/bottleneck/dechave4/Puma/data/gVCF/2024/\${ID}_chr${i}.g.vcf.gz"

	) > "run_GATK_HC_bottleneck_Pumas.sh"

	sbatch run_GATK_HC_bottleneck_Pumas.sh

done
