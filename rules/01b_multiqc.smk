rule multiqc:
    input:
        expand(rules.fastqc.output.html_fwd, smp=sample_id),
        expand(rules.fastqc.output.html_rev, smp=sample_id)
    output:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/01_qc/01b_multiqc/multiqc_init/fastq_multiqc.html"
    log:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/01_qc/01b_multiqc/multiqc_init/logs/multiqc.log"
    wrapper:
        "0.35.0/bio/multiqc"
