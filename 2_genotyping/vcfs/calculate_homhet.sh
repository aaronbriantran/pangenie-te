#!/bin/bash
#SBATCH --job-name=3_homhet
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=1:00:00
#SBATCH --output=/scratch/atran/final/3_pangenie/logs/3_homhet_%a.log
#SBATCH --error=/scratch/atran/final/3_pangenie/logs/3_homhet_%a.err
#SBATCH --array=1,7,9

# Choose one of the following fashion
#SBATCH --mem=10GB


set -e
# set -e is important: it tells bash to exit if any errors occur. Otherwise bash will continue executing commands after error.

# this command writes vcfs from the cereal files produced by pangenie.sh and converts to biallelic by invoking the python script

# takes much less memory and really only uses one thread, so give it a little bit of memory and some time to get all the writing done.


filename=$(awk -v row="${SLURM_ARRAY_TASK_ID}" -F',' 'NR==row {print $1}' ../pangenie_input.csv)
donorname=$(awk -v row="${SLURM_ARRAY_TASK_ID}" -F',' 'NR==row {print $3}' ../pangenie_input.csv)

vcf="${donorname}_genotyping_biallelic.vcf"

ml bcftools

bcftools view -g het -i 'GT="alt"' ${vcf} > ${donorname}_het.vcf
bcftools view -g hom -i 'GT="alt"' ${vcf} > ${donorname}_hom.vcf

numHets=$(wc -l ${donorname}_het.vcf)
numHom=$(wc -l ${donorname}_hom.vcf)
echo $numHets
echo $numHom
ratio=$(($numHets/$numHom))
echo $ratio

rm ${donorname}_het.vcf
rm ${donorname}_hom.vcf
