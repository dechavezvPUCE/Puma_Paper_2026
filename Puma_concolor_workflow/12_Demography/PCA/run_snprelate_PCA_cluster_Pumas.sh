#! /bin/bash

#SBATCH -N 1  # number of nodes
#SBATCH -n 1  # number of tasks (default: allocates 1 core per task)
#SBATCH -t 0-04:00:00   # time in d-hh:mm:ss
#SBATCH -o /data/CEM/bottleneck/dechave4/Puma/log/ROH.%j.out # file to save job's STD$
#SBATCH -e /data/CEM/bottleneck/dechave4/Puma/log/ROH.%j.err # file to save job's STD$
#SBATCH --mail-type=ALL # Send an e-mail when a job starts, stops, or fails
#SBATCH --mail-user=dechave4@asu.edu # Mail-to address
#SBATCH --export=NONE   # Purge the job-submitting shell environment
#SBATCH --mem-per-cpu=10000

source /u/local/Modules/default/init/modules.sh
#module load R/3.6.0
#module load R/4.1.0
module load R/4.0.2
module load gcc/11.3.0

cd /data/CEM/bottleneck/dechave4/Puma/data/VCF/Puma/Combined/UCLA-Puma/Trimmed/onlyPass

R CMD BATCH /u/home/d/dechavez/project-rwayne/2nd.paper/4-Demography/PCA/snprelate_PCA_cluster_Pumas.R 
