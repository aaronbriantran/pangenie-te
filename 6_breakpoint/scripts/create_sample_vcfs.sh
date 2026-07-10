#!/bin/bash
ml samtools

mkdir -p results/create_sample_vcfs

bcftools +split ../ -Oz -o results/create_sample_vcfs

for sample_vcf in results/create_sample_vcfs/*; do
   tabix -p vcf "${sample_vcf}"
done