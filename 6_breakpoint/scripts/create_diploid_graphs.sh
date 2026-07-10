#!/bin/bash
#SBATCH --job-name=alignment
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --time=01:00:00
#SBATCH --output=logs/create_diploid_graphs.log
#SBATCH --error=logs/create_diploid_graphs.err
#SBATCH --mem=10G


set -e
# set -e is important: it tells bash to exit if any errors occur. Otherwise bash will continue executing commands after error.


ml vg

mkdir -p "results/create_diploid_graphs/{$2}"

reference="/scratch/atran/final/3_pangenie/input_files/CHM13v11Y.fa"

vg autoindex \
   -t "${SLURM_CPUS_PER_TASK}" \
   --target-mem "${SLURM_MEM_PER_NODE}" \
   --workflow giraffe \
   --prefix "results/create_diploid_graphs/{$2}" \
   --ref-fasta "${reference}" \
   --vcf "${1}"
