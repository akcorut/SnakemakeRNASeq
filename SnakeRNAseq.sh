#!/bin/bash
#SBATCH --partition=highmem_p
#SBATCH --job-name=peanut_rna_seq
#SBATCH --ntasks=1
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=200gb

#SBATCH --mail-user=ac32082@uga.edu
#SBATCH --mail-type=END,FAIL
#SBATCH --output=peanut_rna_seq.%j.out
#SBATCH --error=peanut_rna_seq.%j.err
#SBATCH --export=NONE

source /apps/lmod/lmod/init/zsh

cd /scratch/ac32082/02.PeanutRNASeq/peanut_rnaseq_scripts/snakemake_workflows/peanut_rna_seq_analysis

module load Anaconda3/5.0.1
source activate snake_conda

export LC_ALL=en_SG.utf8
export LANG=en_SG.utf8

snakemake -n --use-conda --verbose --cores 20 --latency-wait 6000 --rerun-incomplete -s Snakefile