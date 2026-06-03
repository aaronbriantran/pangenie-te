#!/bin/bash`
#SBATCH --job-name=4_shapeit
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --time=1:00:00
#SBATCH --output=/scratch/atran/final/4_shapeit/logs/4_shapeit_%a.log
#SBATCH --error=/scratch/atran/final/4_shapeit/logs/4_shapeit_%a.err
#SBATCH --array=1,7,9

# Choose one of the following fashion
#SBATCH --mem=10GB


set -e
# set -e is important: it tells bash to exit if any errors occur. Otherwise bash will continue executing commands after error.

#for compute:
#https://pmc.ncbi.nlm.nih.gov/articles/PMC9581364/#sec002
#for a single trio, expect less than 10 Gb memory and 1 hour CPU time on 4 cores, so really like 15 minutes, let's give it 30 to be nice. clearly a very light app.

#find vcfs (based on SLURM TASK ID)
#split vcfs by chromosome
#create a script that creates splitting coordinates of 20 cM (20Mb) with 2Mb overlaps (need to know how long the chr is)
#create a script that creates splitting coordinates of 2.5 Mb with 0.5Mb bigger region of the scaffold on each side (think about overlaps between input regions...?)
#that gets put into a file that we awk and iterate through.
#command for phase common below
#use the right names so we can ls -1v > file.txt and ligate using 
#ligate
#command for phase rare below
#bcftools concat --naive


#need to get the right reference. MAKE SURE TO EDIT THE REFERENCE TO BE BY CHROMOSOME!

donorname=$(awk -v row="${SLURM_ARRAY_TASK_ID}" -F',' 'NR==row {print $3}' /scratch/atran/final/3_pangenie/pangenie_input.csv)
vcffile="/scratch/atran/final/3_pangenie/vcfs/${donorname}_alt_biallelic.vcf"

# common variant phasing per chromosome
for filename in $(ls ./inputs/recombination_maps/*gmap*); do
	./binaries/phase_common_static --input ./vcfs/${donorname}_genotyping_biallelic.vcf \
		--reference [reference haplotypes vcf] \
		--pedigree ./inputs/family_file/target.family.fam \
		--map [.map.gz recombination map] \
		--output [output of common variants] \
		--thread 4
done

# concatenate the chromosomal outputs

# rare variant phasing CURRENTLY IGNORED ("We recommend to use phase_rare for datasets with a sample size greater than 2,000 samples. For smaller smaple sizes, phase_common could do the job." <- from the documentation)
#./binaries/phase_rare_static --input [vcf of the target] \
#       --scaffold [output of common variants] \
#       --pedigree [.fam pedigree file]
#       --map [.map.gz recombination map] \
#       --
