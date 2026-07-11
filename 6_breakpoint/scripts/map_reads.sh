#!/bin/bash
#SBATCH --job-name=vg_giraffe
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=32
#SBATCH --time=10:00:00
#SBATCH --output=logs/map_reads.log
#SBATCH --error=logs/map_reads.err
#SBATCH --mem=150G

read1="/scratch/atran/final/1_reads/wgs/F1_1_WGS_MGI_L001_R1.fastq"
read2="/scratch/atran/final/1_reads/wgs/F1_1_WGS_MGI_L001_R2.fastq"
index_prefix="results/create_diploid_graphs/${1}/${1}"

#TODO fix pathing to inputs, wait for other scripts first

mkdir -p results/map_reads

vg giraffe \
   --progress \
   -t "${SLURM_CPUS_PER_TASK}" \
   -d "${index_prefix}.dist" \
   -Z "${index_prefix}.giraffe.gbz" \
   -m "${index_prefix}.min" \
    -i -f "${read1}" -f "${read2}" \
    -o BAM -b default > "results/map_reads/${1}.bam"
