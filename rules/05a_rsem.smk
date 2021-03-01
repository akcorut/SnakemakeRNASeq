rule rsem_genome:
    input:
        gff= config["ref"]["annotation"],
        fasta = REFERENCE
    output:
        rsemindex = config["rsem"]["rsemindex"] + ".n2g.idx.fa"
    threads: 24
    params:
        ref_name = lambda wildcards, output: output[0][:-11]
    conda:
        "../envs/rsem.yaml"
    shell:
        """
        rsem-prepare-reference \
        -p {threads} \
        --gff3 {input.gff} {input.fasta} {params.ref_name}
        """

rule rsem_calculate:
    input:
        bam= rules.star_pass2.output.tcp_bam
    output:
        genes = "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/05_quantification/05a_rsem/genes/{smp}.genes.results",
        stat = directory("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/05_quantification/05a_rsem/genes/{smp}.stat")
    params:
        genomedir= config["rsem"]["rsemindex"],
        prefix = lambda wildcards, output: output[0][:-14]
    threads: 24
    conda:
        "../envs/rsem.yaml"
    shell:
        """
        rsem-calculate-expression \
        --no-qualities \
        -p {threads} \
        --strandedness reverse \
        --alignments --paired-end {input.bam} {params.genomedir} {params.prefix}
        """

rule multiqc_rsem:
    input:
       expand(rules.rsem_calculate.output.stat, smp=sample_id)
    output:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/05_quantification/05a_rsem/rsem_multiqc.html"
    log:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/05_quantification/05a_rsem/logs/multiqc.log"
    wrapper:
        "0.49.0/bio/multiqc"