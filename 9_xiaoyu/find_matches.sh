#!/bin/bash
#SBATCH --job-name=find_meis
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=0:10:00
#SBATCH --output=/scratch/atran/final/9_xiaoyu/logs/9_find_meis_%a.log
#SBATCH --error=/scratch/atran/final/9_xiaoyu/logs/9_find_meis_%a.err
#SBATCH --array=1,7,9

# Choose one of the following fashion
#SBATCH --mem=100MB


set -e
# set -e is important: it tells bash to exit if any errors occur. Otherwise bash will continue executing commands after error.

donorname=$(awk -v row="${SLURM_ARRAY_TASK_ID}" -F',' 'NR==row {print $3}' /scratch/atran/final/3_pangenie/pangenie_input.csv)
vcffile="/scratch/atran/final/3_pangenie/vcfs/${donorname}_genotyping_biallelic.vcf"
fainfo="/scratch/atran/final/3_pangenie/input_files/CHM13v11Y.fa.fai"
bedfile="./xiaoyu.bed"
slop=100

ml bedtools
ml bcftools

#slop xiaoyu's annotations to increase range of intersects
#bedtools slop -i ${bedfile} -g ${fainfo} -b $slop > $slop/xiaoyu_slop.bed

#filter vcf to INDELs where the sample has an MEI
bcftools view -i '(ID ~ "INS" && GT="alt") || (ID ~ "DEL" && GT="ref")' ${vcffile} > ${donorname}_indels.vcf

#overlap INDELs against annotations where the indel starts in the slop radius
bedtools intersect -a ${donorname}_indels.vcf -b $slop/xiaoyu_slop.bed -wb -g ${fainfo} > $slop/${donorname}_intersect.vcf

#filter intersection by whether it is seen as a INS/DEL in the bedfile and if the length is within 10%
awk '{
    # Get length from end of column 3 (split on "-")
    n = split($3, a, "-")
    len1 = a[n]
    vtype1 = a[3]

    # Column 15 is the number after AluY (0-indexed: fields 10-17 are the extra cols)
    # Count your fields to confirm — based on your example, it looks like field 15
    len2 = $15

    # Check within 10% and right type
    if (len1 > 0 && len2 > 0) {
        ratio = (len1 > len2) ? len1/len2 : len2/len1
        if (ratio <= 1.1) {
		if (vtype1 == $17) print $0
		}
    }
}' $slop/${donorname}_intersect.vcf > $slop/${donorname}_matches.vcf

#create sets for each GQ
for gq in 10 20 30 50; do
    awk -v threshold="$gq" '{
        n = split($10, gt, ":")
        gq_val = gt[n]
        if (gq_val + 0 >= threshold) print $0
    }' $slop/${donorname}_matches.vcf > $slop/${donorname}_matches_gq${gq}.vcf
done
