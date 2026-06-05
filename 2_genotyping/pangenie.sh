#!/bin/bash
#SBATCH --job-name=pangenie_genotyping
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=24
#SBATCH --time=2:30:00
#SBATCH --output=/scratch/atran/final/3_pangenie/logs/3_pangenie_%a.log
#SBATCH --error=/scratch/atran/final/3_pangenie/logs/3_pangenie_%a.err
#SBATCH --array=1,7,9

# Choose one of the following fashion
#SBATCH --mem=60GB


set -e
# set -e is important: it tells bash to exit if any errors occur. Otherwise bash will continue executing commands after error.

# compute based on Supplementary Table S5 in the PanGenie paper and the PanGenie documentation. Because I can't
# account for the kmer-counting step, I make very conservative compute estimates.

# -t only uses 23 threads because there are only 23 chromosomes in the vcf, and -t maxes out at the number of chromosomes
# proof: cntrl-F "Largest number of threads" in the PanGenie README
# proof: awk '!/^#/ {print $1}' multiallelic.vcf | sort | uniq

filename=$(awk -v row="${SLURM_ARRAY_TASK_ID}" -F',' 'NR==row {print $1}' ./pangenie_input.csv)
donorname=$(awk -v row="${SLURM_ARRAY_TASK_ID}" -F',' 'NR==row {print $3}' ./pangenie_input.csv)

# run sample with -w to prep cereals for vcf writing later
./binaries/PanGenie -f ./index/pangenome -i ${filename} -s ${donorname} -j 24 -t 23 -w -o ./pangenie_outputs/${donorname}

# see vcfoutput.sh for more details
