import glob
import os
import json
import pandas as pd
from snakemake.io import expand
from snakemake.utils import R
from snakemake.io import glob_wildcards
import re
from os.path import join, basename, dirname
import pathlib
from os import path

############# Load Config File and Sample Names ################

configfile: "config.yaml"

INPUT_DIR = config["samples"]["path"]
REFERENCE = config["ref"]["reference"]
ANNOTATION = config["ref"]["annotation"]
TRANSCRIPTS = config["ref"]["transcript"]

samples = pd.read_table(config["samples"]["all"], dtype=str).set_index("sample", drop=False)
sample_id = samples['sample'].tolist()

# meristem_samples = pd.read_csv(config["samples"]["meristem"]).set_index("sample_meristem", drop=False)
# leaf_samples = pd.read_csv(config["samples"]["leaf"]).set_index("sample_leaf", drop=False)

############# Helper Functions ################

def GetFastq(wildcards):
    return samples.loc[(wildcards.smp), ["r1", "r2"]]

def GetReads(num, wildcards):
    trim1="/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/02_trim/{smp}_R1_val_1.fq.gz"
    trim2="/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/02_trim/{smp}_R2_val_2.fq.gz"
    if config["trimming"]["skip"]:
        return samples.loc[(wildcards.smp), ["r1", "r2"]]
    else:
        sample_list = [trim1, trim2]
        return sample_list[num];

def GetClean(num):
    clean1="/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/03_decontamination/03b_rrna_cleaned/{smp}_R1_clean.fq"
    clean2="/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/03_decontamination/03b_rrna_cleaned/{smp}_R2_clean.fq"
    trim1="/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/02_trim/{smp}_R1_val_1.fq.gz"
    trim2="/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/02_trim/{smp}_R2_val_2.fq.gz"
    if config["decontamination"]["skip"]:
        sample_list = [trim1,trim2]
    else:
        sample_list = [clean1, clean2]
    return sample_list[num]