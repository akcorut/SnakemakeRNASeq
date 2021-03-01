# SnakeRNASeq
A Snakemake workflow to process paired-end RNA-Seq data.

## Steps:

**The workflow consists following steps:**

- Quality control of the raw and/or trimmed data (FastQC, MultiQC)
- Adapter trimming w/ trim_galore (Optional)
- Contamination check and decontamination (Optional)
- Alignment to the reference genome (hisat2, STAR)
- Alignment quality control with RSeQC, QualiMap
- Transcript/gene quantification (StringTie, featureCounts, RSEM)
- Alignment-free transcript quantification (kallisto/salmon)

**Future additions:**
- Differential gene expression analysis (deseq2)
- Machine learning-based mapping uncertainty analysis (GeneQC)

![dag](https://user-images.githubusercontent.com/42179487/109564224-c13f9580-7aae-11eb-9bd6-60f1adb65c60.png)





