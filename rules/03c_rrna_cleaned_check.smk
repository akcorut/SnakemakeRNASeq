############################ After Decontamination #####################################

rule bwa_mem_decontamination:
    input:
        r1=rules.bbmap.output.out1,
        r2=rules.bbmap.output.out2,
        rrna=config["rRNA"]
    output:
        temp("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/03_decontamination/03c_rrna_cleaned_check/{smp}_clean_rrna.sam")
    threads:16
    conda:
        "../envs/bwa.yaml"
    shell:
        '''
        bwa mem -t {threads} {input.rrna} {input.r1} {input.r2} > {output}
        '''

rule sam_to_bam_decontamination:
    input:
        sam=rules.bwa_mem_decontamination.output
    output:
        temp("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/03_decontamination/03c_rrna_cleaned_check/bam/{smp}_clean_rrna.bam")
    threads:16
    conda:
        "../envs/samtools.yaml"
    shell:
        '''
        samtools view -@ {threads} -bS -o {output} {input.sam}
        '''

rule stats_decontamination:
    input:
        bam=rules.sam_to_bam_decontamination.output
    output:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/03_decontamination/03c_rrna_cleaned_check/stats/{smp}_clean_rrna_stats.out"
    threads:16
    conda:
        "../envs/samtools.yaml"
    shell:
        '''
        samtools stats {input.bam} -@ {threads} > {output}
        '''

rule multiqc_rrna_decontamination:
    input:
        expand(rules.sam_to_bam_decontamination.output, smp=sample_id),
        expand(rules.stats_decontamination.output, smp=sample_id)
    output:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/03_decontamination/03c_rrna_cleaned_check/rrna_clean_multiqc_report.html"
    log:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/03_decontamination/03c_rrna_cleaned_check/logs/multiqc.log"
    wrapper:
        "0.48.0/bio/multiqc"