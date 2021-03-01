rule bbmap:
    input:
        r1=rules.trim_galore_pe.output.trim1,
        r2=rules.trim_galore_pe.output.trim2,
        rrna=config["rRNA"]
    output:
        out1="/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/03_decontamination/03b_rrna_cleaned/{smp}_R1_clean.fq",
        out2="/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/03_decontamination/03b_rrna_cleaned/{smp}_R2_clean.fq",
        stats="/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/03_decontamination/03b_rrna_cleaned/stats/{smp}_bbsplit_stats.txt"
    params:
        out_rrna="/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/03_decontamination/03b_rrna_cleaned/rrna/{smp}",
        index= config["bb_index"]
    log:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/03_decontamination/03b_rrna_cleaned/logs/{smp}_decontamination.log"
    conda:
        "../envs/bbmap.yaml"
    threads:16
    shell:
        """
        bbsplit.sh -Xmx120g threads={threads} in1={input.r1} in2={input.r2} ref_rrna={input.rrna} path={params.index} basename={params.out_rrna}/out_%.fq outu1={output.out1} outu2={output.out2} refstats={output.stats} 2> {log}
        """

rule fastqc_clean:
    input:
        r1=rules.bbmap.output.out1,
        r2=rules.bbmap.output.out2
    output:
        html1 = "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/01_qc/01a_fqc/fqc_clean/{smp}_R1_clean_fastqc.html",
        zip1 = "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/01_qc/01a_fqc/fqc_clean/{smp}_R1_clean_fastqc.zip",
        html2 = "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/01_qc/01a_fqc/fqc_clean/{smp}_R2_clean_fastqc.html",
        zip2 = "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/01_qc/01a_fqc/fqc_clean/{smp}_R2_clean_fastqc.zip"
    params:
        prefix="/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/01_qc/01a_fqc/fqc_clean/"
    conda:
        "../envs/fastqc.yaml"
    threads:20
    shell:
        """
        fastqc -t {threads} {input.r1} {input.r2} -q -f fastq -o {params.prefix}
        """

rule multiqc_clean:
    input:
        expand(rules.fastqc_clean.output.html1, smp=sample_id),
        expand(rules.fastqc_clean.output.html2, smp=sample_id)
    output:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/01_qc/01b_multiqc/multiqc_clean/multiqc_report_decont.html"
    log:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/01_qc/01b_multiqc/multiqc_clean/logs/multiqc.log"
    wrapper:
        "0.47.0/bio/multiqc"