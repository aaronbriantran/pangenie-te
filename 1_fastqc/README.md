@author Aaron Tran
@date June 8, 2026

This step performs basic QC steps for the WGS fasta files, which I will use later for genotyping from a pangenome graph.

This step uses the following modules:
* fastqc/0.12.1
* multiqc/1.17 (defined in config/multiqc.yml)
Input:
* WGS reads (including technincal replicates) from all three donors

Output:
* FastQC reports, summarized by MultiQC