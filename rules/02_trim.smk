rule trim_galore_pe:
    input:
        GetFastq
    output:
        trim1="/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/02_trim/{smp}_R1_val_1.fq.gz",
        report1="/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/02_trim/{smp}_R1.fastq.gz_trimming_report.txt",
        trim2="/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/02_trim/{smp}_R2_val_2.fq.gz",
        report2="/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/02_trim/{smp}_R2.fastq.gz_trimming_report.txt"
    params:
        extra="--illumina -q 20"
    log:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/02_trim/logs/{smp}.log"
    wrapper:
        "0.35.2/bio/trim_galore/pe"

rule fastqc_trim:
    input:
        r1=rules.trim_galore_pe.output.trim1,
        r2=rules.trim_galore_pe.output.trim2
    output:
        html1="/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/01_qc/01a_fqc/fqc_trim/{smp}_R1_val_1_fastqc.html",
        zip1="/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/01_qc/01a_fqc/fqc_trim/{smp}_R1_val_1_fastqc.zip",
        html2="/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/01_qc/01a_fqc/fqc_trim/{smp}_R2_val_2_fastqc.html",
        zip2="/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/01_qc/01a_fqc/fqc_trim/{smp}_R2_val_2_fastqc.zip"
    conda:
        "../envs/fastqc.yaml"
    threads:20
    params:
        prefix = "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/01_qc/01a_fqc/fqc_trim/"
    shell:
        """
        fastqc -t {threads} {input.r1} {input.r2} -q -f fastq -o {params.prefix}
        """

rule multiqc_trim:
    input:
        expand(rules.fastqc_trim.output.html1, smp=sample_id),
        expand(rules.fastqc_trim.output.html2, smp=sample_id)
    output:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/01_qc/01b_multiqc/multiqc_trim/multiqc_report_trim_galore.html"
    log:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/01_qc/01b_multiqc/multiqc_trim/logs/multiqc.log"
    wrapper:
        "0.49.0/bio/multiqc"

rule trim_galore_multiqc:
    input:
        expand(rules.trim_galore_pe.output.report1, smp=sample_id),
        expand(rules.trim_galore_pe.output.report2, smp=sample_id)
    output:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/02_trim/trim_galore_multiqc_report.html"
    log:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/02_trim/logs/multiqc.log"
    wrapper:
        "0.49.0/bio/multiqc"