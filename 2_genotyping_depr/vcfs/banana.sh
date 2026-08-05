#!/bin/bash


ml bcftools

# ---- Task 0: Merge individual VCFs into one ----
vcf_list=""
for num in 1 7 9; do
    donorname=$(awk -v row="${num}" -F',' 'NR==row {print $3}' /scratch/atran/final/3_pangenie/pangenie_input.csv)
    vcf="/scratch/atran/final/3_pangenie/vcfs/${donorname}_genotyping_biallelic.vcf"
#    bgzip -k ${vcf}
#    echo "bgzipped ${vcf}"
#    bcftools index ${vcf}.gz
#    echo "index ${vcf}"
    vcf_list="${vcf_list} ${vcf}.gz"
done
echo $vcf_list
bcftools merge ${vcf_list} -o ./output/total_genotyping_biallelic.vcf
