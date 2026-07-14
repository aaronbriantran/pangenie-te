#!/bin/bash
#SBATCH --job-name=dip_graph
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=22
#SBATCH --time=02:00:00
#SBATCH --output=logs/manual_diploid_graphs.log
#SBATCH --error=logs/manual_diploid_graphs.err
#SBATCH --mem=150G


set -e
# set -e is important: it tells bash to exit if any errors occur. Otherwise bash will continue executing commands after error.


ml vg/1.49.0

out_dir=results/manual_diploid_graphs/${1}
mkdir -p "${out_dir}"

reference="/scratch/atran/final/3_pangenie/input_files/CHM13v11Y.fa"

#taken directly from "Mapping short reads with Giraffe" in the vg wiki
#compiles a bunch of the chr-subsetted vcfs into an array of flag strings
#that it then supplies to autoindex

#don't quote this as string literals please! causes problems with Bash arrays
VCF_FLAGS=()
VCF_ARGS=()
for CHROM in {1..22}; do
    VCF_FLAGS+=(-v results/create_sample_vcfs/${1}_chr${CHROM}.vcf.gz)
    VCF_ARGS+=(results/create_sample_vcfs/${1}_chr${CHROM}.vcf.gz)
done

#include as many threads as chromosomes
#taken mostly from https://github.com/vgteam/vg/wiki/SV-Genotyping-and-variant-calling
#needs some modifications though!

#construct from all the indexed vcfs
vg construct -t "${SLURM_CPUS_PER_TASK}" -a -r "${reference}" "${VCF_FLAGS[@]}" > "${out_dir}/${1}.vg"

#create the xg
vg index -t "${SLURM_CPUS_PER_TASK}" "${out_dir}/${1}.vg" -L -x "${out_dir}/${1}.xg"

#create the gbwt (not from vg index, but vg gbwt)
#TODO: don't load VCF flags, instead pass VCFs as arguments directly!
vg gbwt --num-threads "${SLURM_CPUS_PER_TASK}" -x "${out_dir}/${1}.xg" -o "${out_dir}/${1}.gbwt" "${VCF_ARGS[@]}" 

#load the gbwt as an argument, take an input xg graph, and create a GBZ graph
vg gbwt --num-threads "${SLURM_CPUS_PER_TASK}" -x "${out_dir}/${1}.xg" "${out_dir}/${1}.gbwt" -g "${out_dir}/${1}.gbz" --gbz-format

#create the distance index
vg index -t "${SLURM_CPUS_PER_TASK}" -j "${out_dir}/${1}.dist" "${out_dir}/${1}.gbz"

#create the minimizer index
vg minimizer test.gbz -t "${out_dir}/${1}.gbz" -d "${out_dir}/${1}.dist" -o "${out_dir}/${1}.withzip.min" -z "${out_dir}/${1}.zipcodes"