#!/bin/bash
#SBATCH --job-name=dip_genotype
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=16
#SBATCH --time=01:00:00
#SBATCH --output=logs/pack_and_call.log
#SBATCH --error=logs/pack_and_call.err
#SBATCH --mem=50G
in_dir=results/${2}/${1}
out_dir=results/pack_and_call/${1}

mkdir -p "${out_dir}"

# Compute the read support (use -a instead of -g for .gaf.gz input)
# right mapping quality filter?
vg pack --progress -t "${SLURM_CPUS_PER_TASK}" -x "${in_dir}/${1}.gbz" -g results/map_reads/F1.gam -o "${out_dir}/${1}.pack" -Q 5

# Genotype the graph (add -a to genotype all sites including 0/0)
# The -z option restricts possible alleles to haplotypes in the GBZ which is usually faster and more accurate but only applies to GBZ input
vg call --progress -t "${SLURM_CPUS_PER_TASK}" "${in_dir}/${1}.gbz" -k "${out_dir}/${1}.pack" -s "${1}" -z > "${1}_${2}_.vcf"