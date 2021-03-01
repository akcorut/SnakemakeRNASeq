rule gff3_to_gtf:
    input:
        anno = config["ref"]["annotation"]
    output:
        gtf = config["ref"]["path"] + "/TIFRUNNER_gene_models.gtf"
    conda:
        "../envs/gffread.yaml"
    shell:
        "gffread {input.anno} -T -o {output.gtf}"

rule star_index:
    input:
        fasta = REFERENCE,
        gtf = rules.gff3_to_gtf.output.gtf
    output:
        directory(config["ref"]["star_index"])
    threads:12
    params:
        extra = ""
    log:
        config["ref"]["star_index"] + "/log/star_index.log"
    wrapper:
        "0.49.0/bio/star/index"

rule star_pass1:
    input:
        fq1=GetClean(0),
        fq2=GetClean(1),
        index= rules.star_index.output
    output:
        bam="/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04a_alignment_results/star/pass1/{smp}/Aligned.out.bam",
        sj="/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04a_alignment_results/star/pass1/{smp}/SJ.out.tab"
    log:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04a_alignment_results/star/pass1/logs/{smp}.log"
    params:
        # path to STAR reference genome index
        index=config["ref"]["star_index"],
        extra="--outSAMtype BAM Unsorted --alignIntronMax 10000 --sjdbGTFfile {}".format(
              rules.gff3_to_gtf.output.gtf)
    threads:20
    wrapper:
        "0.49.0/bio/star/align"

rule get_junctions:
    input:
        expand(rules.star_pass1.output.sj, smp=sample_id)
    output:
        sj="/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04a_alignment_results/star/junctions/SJ.filtered.tab"
    shell:
        """
        cat {input} | awk '($5 > 0 && $7 > 2 && $6==0)' | cut -f1-6 | sort | uniq > {output}
        """

rule star_pass2:
    input:
        fq1=GetClean(0),
        fq2=GetClean(1),
        sj=rules.get_junctions.output.sj
    output:
        bam="/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04a_alignment_results/star/pass2/{smp}/Aligned.out.bam",
        tcp_bam="/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04a_alignment_results/star/pass2/{smp}/Aligned.toTranscriptome.out.bam",
        sorted_bam="/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04a_alignment_results/star/pass2/{smp}/Aligned.sortedByCoord.out.bam",
        gene_counts="/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04a_alignment_results/star/pass2/{smp}/ReadsPerGene.out.tab",
        log_final="/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04a_alignment_results/star/pass2/{smp}/Log.final.out"
    log:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04a_alignment_results/star/pass2/logs/{smp}.log"
    params:
        # path to STAR reference genome index
        index=config["ref"]["star_index"],
        extra="--outSAMunmapped Within --outSAMtype BAM SortedByCoordinate Unsorted --quantMode GeneCounts TranscriptomeSAM --alignIntronMax 10000 --sjdbFileChrStartEnd {} --sjdbGTFfile {}".format(
              rules.get_junctions.output.sj, rules.gff3_to_gtf.output.gtf)
    threads:20
    wrapper:
        "0.49.0/bio/star/align"