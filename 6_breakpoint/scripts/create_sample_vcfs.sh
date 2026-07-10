#!/bin/bash
ml samtools

mkdir -p "results/create_sample_vcfs"

#split phased vcf into vcfs per sample
bcftools +split "${1}" -Oz -o results/create_sample_vcfs

#use query to get the sample names, find the sample vcf, and split by chromosomes using bcftools view
for sampName in $(bcftools query -l ../5_phasing/results/phased_complete.bcf 2> /dev/null); do
   total_samp_vcf="results/create_sample_vcfs/${sampName}.vcf.gz"
   for chr in {1..22}; do
      chr_split="results/create_sample_vcfs/${sampName}_chr${chr}.vcf.gz"
      bcftools view \
         -r "chr${chr}" \
         -0z -o "${chr_split}" \
         "${total_samp_vcf}"
      tabix -p vcf "${chr_split}"
   done
done