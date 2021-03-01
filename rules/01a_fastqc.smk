rule fastqc:
    input:
        GetFastq
    output:
        html_fwd="/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/01_qc/01a_fqc/fqc_init/{smp}_R1_fastqc.html",
        zip_fwd="/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/01_qc/01a_fqc/fqc_init/{smp}_R1_fastqc.zip",
        html_rev="/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/01_qc/01a_fqc/fqc_init/{smp}_R2_fastqc.html",
        zip_rev="/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/01_qc/01a_fqc/fqc_init/{smp}_R2_fastqc.zip"
    conda:
        "../envs/fastqc.yaml"
    params:
        prefix = "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/01_qc/01a_fqc/fqc_init"
    threads:20
    log:
        log_fwd="/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/01_qc/01a_fqc/fqc_init/logs/{smp}_R1.fastqc.log",
        log_rev="/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/01_qc/01a_fqc/fqc_init/logs/{smp}_R2.fastqc.log"
    shell:
        """
        fastqc --outdir {params.prefix} -t {threads} -f fastq {input}
        """
