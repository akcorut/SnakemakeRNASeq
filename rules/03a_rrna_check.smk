rule bwa_mem:
    input:
        r1=rules.trim_galore_pe.output.trim1,
        r2=rules.trim_galore_pe.output.trim2,
        rrna=config["rRNA"]
    output:
        temp("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/03_decontamination/03a_rrna_check/{smp}_rrna.sam")
    threads:16
    conda:
        "../envs/bwa.yaml"
    shell:
        '''
        bwa mem -t {threads} {input.rrna} {input.r1} {input.r2} > {output}
        '''

rule sam_to_bam:
    input:
        sam=rules.bwa_mem.output
    output:
        temp("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/03_decontamination/03a_rrna_check/bam/{smp}_rrna.bam")
    threads:16
    conda:
        "../envs/samtools.yaml"
    shell:
        '''
        samtools view -@ {threads} -bS -o {output} {input.sam}
        '''

rule flagstat:
    input:
        bam=rules.sam_to_bam.output
    output:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/03_decontamination/03a_rrna_check/flagstat/{smp}_rrna.out"
    threads:16
    conda:
        "../envs/samtools.yaml"
    shell:
        '''
        samtools flagstat {input.bam} --threads {threads} > {output}
        '''

rule stats:
    input:
        bam=rules.sam_to_bam.output
    output:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/03_decontamination/03a_rrna_check/stats/{smp}_rrna_stats.out"
    threads:16
    conda:
        "../envs/samtools.yaml"
    shell:
        '''
        samtools stats {input.bam} > {output}
        '''

rule multiqc_rrna:
    input:
        expand(rules.flagstat.output, smp=sample_id),
        expand(rules.sam_to_bam.output, smp=sample_id),
        expand(rules.stats.output, smp=sample_id)
    output:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/03_decontamination/03a_rrna_check/rrna_multiqc_report.html"
    log:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/03_decontamination/03a_rrna_check/logs/multiqc.log"
    wrapper:
        "0.48.0/bio/multiqc"