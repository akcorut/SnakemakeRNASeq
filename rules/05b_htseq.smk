rule htseq_count:
    input:
        rules.star_pass2.output.sorted_bam
    output:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/05_quantification/05b_htseq/{smp}_htseq.cnt"
    conda:
        "../envs/htseq.yaml"
    params:
        gtf= rules.gff3_to_gtf.output.gtf
    log:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/05_quantification/05b_htseq/{smp}_htseq_count.log"
    threads: 24
    shell:
        """
        htseq-count -m intersection-nonempty --stranded=reverse --idattr gene_id -r pos -f bam {input} {params.gtf} > {output} 2> {log}
        """

rule htseq_multiqc:
    input:
        expand(rules.htseq_count.output, smp=sample_id)
    output:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/05_quantification/05b_htseq/htseq_multiqc.html"
    log:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/05_quantification/05b_htseq/logs/multiqc.log"
    params:
        prefix = lambda wildcards, output: output[0][:-18]
    conda:
        "../envs/multiqc.yaml"
    shell:
        """
        multiqc -m htseq {params.prefix} --filename {output} 2> {log}
        """
