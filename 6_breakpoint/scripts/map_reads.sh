#!/bin/bash
#SBATCH --job-name=vg_giraffe
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=32
#SBATCH --time=1:30:00
#SBATCH --output=logs/map_reads_gtype.log
#SBATCH --error=logs/map_reads_gtype.err
#SBATCH --mem=60G

read1="/scratch/atran/final/1_reads/wgs/F1_1_WGS_MGI_L001_R1.fastq"
read2="/scratch/atran/final/1_reads/wgs/F1_1_WGS_MGI_L001_R2.fastq"
index_prefix="results/manual_diploid_graphs/${1}/${1}"

#TODO fix pathing to inputs, wait for other scripts first

mkdir -p results/map_reads_gtyped

vg giraffe \
   --progress \
   -t "${SLURM_CPUS_PER_TASK}" \
   -d "${index_prefix}.dist" \
   -Z "${index_prefix}.gbz" \
   -m "${index_prefix}.withzip.min" \
   -f "${read1}" -f "${read2}" \
   -o GAM -b default > "results/map_reads_gtyped/${1}.gam"
