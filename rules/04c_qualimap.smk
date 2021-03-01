rule sort_bam:
    input:
        bam= rules.star_pass2.output.sorted_bam
    output:
        temp("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04b_alignment_qc/qualimap/SortedBam/{smp}_sorted.bam")
    params:
        prfx=lambda wildcards, output: output[0][:-4]
    conda:
        "../envs/samtools.yaml"
    threads:20
    shell:
        '''
        samtools sort -@ {threads} -n -o {output} -T {params.prfx} {input.bam}
        '''

rule qualimap:
    input: 
        sorted_bam= rules.sort_bam.output
    output: 
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04b_alignment_qc/qualimap/{smp}/qualimapReport.html"
    params:
        outdir=lambda wildcards, output: output[0][:-20],
        gtf= rules.gff3_to_gtf.output.gtf
    conda:
        "../envs/qualimap.yaml"
    shell:
        '''
        qualimap rnaseq -bam {input.sorted_bam} -gtf {params.gtf} --outdir {params.outdir} --sorted --paired
        '''

rule multiqc_qualimap:
    input:
        expand(rules.qualimap.output, smp=sample_id)
    output:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04b_alignment_qc/qualimap/qualimap_multiqc.html"
    log:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04b_alignment_qc/qualimap/logs/multiqc.log"
    wrapper:
        "0.49.0/bio/multiqc"