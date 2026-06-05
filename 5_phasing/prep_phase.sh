#!/bin/bash
#SBATCH --job-name=4_shapeit_prep
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --time=1:00:00
#SBATCH --output=/scratch/atran/final/4_shapeit/logs/4_shapeit_prep.log
#SBATCH --error=/scratch/atran/final/4_shapeit/logs/4_shapeit_prep.err

# Choose one of the following fashion
#SBATCH --mem=50GB


set -e
# set -e is important: it tells bash to exit if any errors occur. Otherwise bash will continue executing commands after error.

ml bcftools
ml samtools


# ---- Global variables ----
fai="/scratch/atran/final/3_pangenie/input_files/CHM13v11Y.fa.fai"
buffer=100000

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

# ---- Task 2: Split merged VCF by chromosome ----
for chr in {1..22} X; do
    bcftools view -r chr${chr} ./output/total_genotyping_biallelic.vcf \
        -Ov -o ./output/total_chr${chr}_genotyping_biallelic.vcf
done

# ---- Task 3: Common phasing chunk coordinates (20 Mb, 2 Mb overlap) ----
chunk_size=20000000
overlap=2000000

> ./output/chunk_sizes_common.txt

for chr in {1..22} X; do
    chrlen=$(awk -v c="chr${chr}" '$1==c {print $2}' ${fai})
    chrlen=$((chrlen + buffer))
    start=1

    while [ ${start} -lt ${chrlen} ]; do
        end=$((start + chunk_size - 1))
        [ ${end} -gt ${chrlen} ] && end=${chrlen}
        echo "chr${chr}:${start}-${end}" >> ./output/chunk_sizes_common.txt
        start=$((end - overlap + 1))
    done
done

# ---- Task 4: Rare phasing chunk coordinates (2.5 Mb, 0.5 Mb scaffold) ----
chunk_size=2500000
scaffold=500000

> ./output/chunk_sizes_rare.txt

for chr in {1..22} X; do
    chrlen=$(awk -v c="chr${chr}" '$1==c {print $2}' ${fai})
    chrlen=$((chrlen + buffer))
    start=1

    while [ ${start} -lt ${chrlen} ]; do
        end=$((start + chunk_size - 1))
        [ ${end} -gt ${chrlen} ] && end=${chrlen}

        scaffold_start=$((start - scaffold))
        [ ${scaffold_start} -lt 1 ] && scaffold_start=1
        scaffold_end=$((end + scaffold))
        [ ${scaffold_end} -gt ${chrlen} ] && scaffold_end=${chrlen}

        echo -e "chr${chr}:${scaffold_start}-${scaffold_end}\tchr${chr}:${start}-${end}" >> ./output/chunk_sizes_rare.txt

        start=$((end + 1))
    done
done
