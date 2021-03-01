"""
Author: Kivanc Corut
A Snakemake workflow to process paired end RNA-Seq data.
"""

include: "rules/00_common.smk"

############################## Target Rules #####################################

ALL_TARGET = []

INIT_QC_R1= expand("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/01_qc/01a_fqc/fqc_init/{smp}_R1_fastqc.html", smp=sample_id)
INIT_QC_R2= expand("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/01_qc/01a_fqc/fqc_init/{smp}_R2_fastqc.html", smp=sample_id)
INIT_MQC= expand("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/01_qc/01b_multiqc/multiqc_init/fastq_multiqc.html")
ALL_TARGET.extend(INIT_QC_R1)
ALL_TARGET.extend(INIT_QC_R2)
ALL_TARGET.extend(INIT_MQC)

if not config["trimming"]["skip"]:
    TRIMMED_R1= expand("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/02_trim/{smp}_R1_val_1.fq.gz", smp=sample_id)
    TRIMMED_R2= expand("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/02_trim/{smp}_R2_val_2.fq.gz", smp=sample_id)
    TRIMMED_MQC= expand("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/02_trim/trim_galore_multiqc_report.html")
    TRIMMED_FQC=expand("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/01_qc/01b_multiqc/multiqc_trim/multiqc_report_trim_galore.html")
    ALL_TARGET.extend(TRIMMED_R1)
    ALL_TARGET.extend(TRIMMED_R2)
    ALL_TARGET.extend(TRIMMED_FQC)
    ALL_TARGET.extend(TRIMMED_MQC)

if not config["decontamination"]["skip"]:
    CHECK_RRNA= expand("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/03_decontamination/03a_rrna_check/rrna_multiqc_report.html")
    CLEAN_R1= expand("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/03_decontamination/03b_rrna_cleaned/{smp}_R1_clean.fq", smp=sample_id)
    CLEAN_R2= expand("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/03_decontamination/03b_rrna_cleaned/{smp}_R2_clean.fq", smp=sample_id)
    CHECK_CLEAN= expand("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/03_decontamination/03c_rrna_cleaned_check/rrna_clean_multiqc_report.html")
    CLEAN_MQC= expand("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/01_qc/01b_multiqc/multiqc_clean/multiqc_report_decont.html")
    ALL_TARGET.extend(CHECK_RRNA)
    ALL_TARGET.extend(CLEAN_R1)
    ALL_TARGET.extend(CLEAN_R2)
    ALL_TARGET.extend(CHECK_CLEAN)
    ALL_TARGET.extend(CLEAN_MQC)

if config["alignment"]["activate"]:
    
    STAR_PASS1= expand("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04a_alignment_results/star/pass1/{smp}/Aligned.out.bam", smp=sample_id)
    STAR_PASS1_SJ= expand("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04a_alignment_results/star/pass1/{smp}/SJ.out.tab", smp=sample_id)
    SPLICE_JUNC= expand("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04a_alignment_results/star/junctions/SJ.filtered.tab")
    STAR_BAM= expand("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04a_alignment_results/star/pass2/{smp}/Aligned.out.bam", smp=sample_id)
    STAR_TCP_BAM= expand("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04a_alignment_results/star/pass2/{smp}/Aligned.toTranscriptome.out.bam", smp=sample_id)
    STAR_SORTED_BAM= expand("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04a_alignment_results/star/pass2/{smp}/Aligned.sortedByCoord.out.bam", smp=sample_id)
    STAR_GENE_COUNT= expand("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04a_alignment_results/star/pass2/{smp}/ReadsPerGene.out.tab", smp=sample_id)
    STAR_RSEQC= expand("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04b_alignment_qc/rseqc/rseqc_multiqc_report.html")
    QUALIMAP_REPORT= expand("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04b_alignment_qc/qualimap/{smp}/qualimapReport.html", smp=sample_id)
    QUALIMAP_MQC= expand("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04b_alignment_qc/qualimap/qualimap_multiqc.html")
    ALL_TARGET.extend(STAR_PASS1)
    ALL_TARGET.extend(SPLICE_JUNC)
    ALL_TARGET.extend(STAR_BAM)
    ALL_TARGET.extend(STAR_TCP_BAM)
    ALL_TARGET.extend(STAR_SORTED_BAM)
    ALL_TARGET.extend(STAR_GENE_COUNT)
    ALL_TARGET.extend(STAR_RSEQC)
    ALL_TARGET.extend(QUALIMAP_REPORT)
    ALL_TARGET.extend(QUALIMAP_MQC)
        
    if config["featurecounts"]["activate"]:
        FCOUNTS_RESULTS= expand("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/feature/featureCounts_results.txt")
        FCOUNTS_MQC= expand("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/feature/feature_multiqc.html")
        ALL_TARGET.extend(FCOUNTS_RESULTS)
        ALL_TARGET.extend(FCOUNTS_MQC)

    if config["rsem"]["activate"]:
        RSEM_INDEX= expand(config["rsem"]["rsemindex"] + ".n2g.idx.fa")
        RSEM_GENES= expand("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/05_quantification/05a_rsem/genes/{smp}.genes.results", smp=sample_id)
        RSEM_MQC= expand("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/05_quantification/05a_rsem/rsem_multiqc.html")
        ALL_TARGET.extend(RSEM_INDEX)
        ALL_TARGET.extend(RSEM_GENES)
        ALL_TARGET.extend(RSEM_MQC)

    if config["htseq"]["activate"]:
        HTSEQ_CNT= expand("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/05_quantification/05b_htseq/{smp}_htseq.cnt", smp=sample_id)
        HTSEQ_MQC= expand("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/05_quantification/05b_htseq/htseq_multiqc.html")
        ALL_TARGET.extend(HTSEQ_CNT)
        ALL_TARGET.extend(HTSEQ_MQC)

if config["alignment_free"]["activate"]:

    if config["salmon"]["activate"]:

        if config["salmon"]["mapping_mode"]: 
            SALMON_QUASI= expand("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/06_alignment_free/06a_salmon/quant/{smp}", smp=sample_id)
            SALMON__QUASI_MQC= expand("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/06_alignment_free/06a_salmon/salmon_multiqc.html")
            ALL_TARGET.extend(SALMON_QUASI)
            ALL_TARGET.extend(SALMON__QUASI_MQC)

        if config["salmon"]["alignment_mode"]:
            SALMON_ALIGN= expand("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/salmon_align/quant/{smp}_salmon_quant_align", smp=sample_id)
            SALMON_ALIGN_MQC=  expand("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/salmon_align/salmon_align_multiqc.html")
            ALL_TARGET.extend(SALMON_ALIGN)
            ALL_TARGET.extend(SALMON_ALIGN_MQC)

    if config["kallisto"]["activate"]:
        KALLISTO_QUANT= expand("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/06_alignment_free/06b_kallisto/quant/{smp}", smp=sample_id)
        KALLISTO_MQC= expand("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/06_alignment_free/06b_kallisto/kallisto_multiqc.html")
        ALL_TARGET.extend(KALLISTO_QUANT)
        ALL_TARGET.extend(KALLISTO_MQC)


rule all:
    input: ALL_TARGET

############# Modules ################

include: "rules/01a_fastqc.smk"
include: "rules/01b_multiqc.smk"
include: "rules/02_trim.smk"
include: "rules/03a_rrna_check.smk"
include: "rules/03b_rrna_clean.smk"
include: "rules/03c_rrna_cleaned_check.smk"
include: "rules/04a_star.smk"
include: "rules/04b_rseqc.smk"
include: "rules/04c_qualimap.smk"
include: "rules/05a_rsem.smk"
include: "rules/05b_htseq.smk"
include: "rules/06a_salmon.smk"
include: "rules/06b_kallisto.smk"


