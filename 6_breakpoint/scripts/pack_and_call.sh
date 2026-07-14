#!/bin/bash

in_dir=results/${2}/${1}
out_dir=results/pack_and_call/${1}

mkdir -p "${out_dir}"

# Compute the read support (use -a instead of -g for .gaf.gz input)
# right mapping quality filter?
vg pack -x "${in_dir}/${1}.gbz" -g results/map_reads/F1.gam -o "${out_dir}/${1}.pack" -Q 5

# Genotype the graph (add -a to genotype all sites including 0/0)
# The -z option restricts possible alleles to haplotypes in the GBZ which is usually faster and more accurate but only applies to GBZ input
vg call "${in_dir}/${1}.gbz" -k "${out_dir}/${1}.pack" -s "${1}" -z > "${1}_${2}_.vcf"