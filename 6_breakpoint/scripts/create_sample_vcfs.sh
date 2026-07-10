#!/bin/bash

bcftools +split ../ -Oz -o results/create_sample_vcfs

for sample_vcf in results/create_sample_vcfs/*; do
   tabix 
done