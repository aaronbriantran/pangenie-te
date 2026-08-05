#!/bin/bash
#SBATCH --job-name=dip_genotype_total
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=16
#SBATCH --time=01:00:00
#SBATCH --output=logs/pack_and_gtype.log
#SBATCH --error=logs/pack_and_gtype.err
#SBATCH --mem=200G

in_dir=results/${2}/${1}
out_dir=results/pack_and_gtype/${1}

mkdir -p "${out_dir}"

#VCF_FLAGS=()
#for CHROM in {1..22}; do
#   VCF_FLAGS+=(-v results/create_sample_vcfs/${1}_chr${CHROM}.vcf.gz)
#done

# Compute the read support (use -a instead of -g for .gaf.gz input)
# right mapping quality filter?
vg pack -t "${SLURM_CPUS_PER_TASK}" -x "${in_dir}/${1}.xg" -g results/map_reads_gtyped/F1.gam -o "${out_dir}/${1}_total.pack" -Q 5

# Genotype the graph (add -a to genotype all sites including 0/0)
# The -z option restricts possible alleles to haplotypes in the GBZ which is usually faster and more accurate but only applies to GBZ input
vg call -t "${SLURM_CPUS_PER_TASK}" "${in_dir}/${1}.xg" -k "${out_dir}/${1}_total.pack" -s "${1}" -v results/create_sample_vcfs/F1.vcf.gz > "${out_dir}/${1}_total.vcf"
