#!/bin/bash
#SBATCH --job-name=alignment
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=22
#SBATCH --time=01:00:00
#SBATCH --output=logs/create_diploid_graphs.log
#SBATCH --error=logs/create_diploid_graphs.err
#SBATCH --mem=15G


set -e
# set -e is important: it tells bash to exit if any errors occur. Otherwise bash will continue executing commands after error.


ml vg

mkdir -p "results/create_diploid_graphs/${2}"

reference="/scratch/atran/final/3_pangenie/input_files/CHM13v11Y.fa"

#taken directly from "Mapping short reads with Giraffe" in the vg wiki
#compiles 
VCF_ARGS=()
for CHROM in {1..22}; do
    VCF_ARGS+=("-v chr${CHROM}.vcf.gz")
done
vg autoindex "${VCF_ARGS[@]}" -p hs37d5-pangenome


vg autoindex \
   -t "${SLURM_CPUS_PER_TASK}" \
   --target-mem "${SLURM_MEM_PER_NODE}" \
   --workflow giraffe \
   --prefix "results/create_diploid_graphs/${2}" \
   --ref-fasta "${reference}" \
   "${VCF_ARGS[@]}"
