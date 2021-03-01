rule gtf2bed:
    input:
        rules.gff3_to_gtf.output.gtf
    output:
        bed="/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04b_alignment_qc/rseqc/tifrunner_annotation.bed",
        db=temp("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04b_alignment_qc/rseqc/tifrunner_annotation.db")
    log:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04b_alignment_qc/rseqc/logs/gtf2bed.log"
    conda:
        "../envs/gffutils.yaml"
    script:
        "../scripts/gtf2bed.py"

# rule gtf2bed:
#     input:
#         rules.gff3_to_gtf.output.gtf
#     output:
#         bed="/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04b_alignment_qc/rseqc/tifrunner_annotation.bed",
#     conda:
#         "../envs/bedops.yaml"
#     shell:
#         "gtf2bed < {input} > {output.bed}"


rule rseqc_junction_annotation:
    input:
        bam=rules.star_pass2.output.bam,
        bed=rules.gtf2bed.output.bed
    output:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04b_alignment_qc/rseqc/{smp}.junctionanno.junction.bed"
    log:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04b_alignment_qc/rseqc/logs/rseqc_junction_annotation/{smp}.log"
    params:
        extra=r"-q 255",  # STAR uses 255 as a score for unique mappers
        prefix=lambda wildcards, output: output[0][:-13]
    conda:
        "../envs/rseqc.yaml"
    shell:
        "junction_annotation.py {params.extra} -i {input.bam} -r {input.bed} -o {params.prefix} "
        "> {log[0]} 2>&1"

rule rseqc_stat:
    input:
        rules.star_pass2.output.bam
    output:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04b_alignment_qc/rseqc/{smp}.stats.txt"
    log:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04b_alignment_qc/rseqc/logs/rseqc_stat/{smp}.log"
    conda:
        "../envs/rseqc.yaml"
    shell:
        "bam_stat.py -i {input} > {output} 2> {log}"

        
rule rseqc_infer:
    input:
        bam=rules.star_pass2.output.bam,
        bed=rules.gtf2bed.output.bed
    output:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04b_alignment_qc/rseqc/{smp}.infer_experiment.txt"
    log:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04b_alignment_qc/rseqc/logs/rseqc_infer/{smp}.log"
    conda:
        "../envs/rseqc.yaml"
    shell:
        "infer_experiment.py -r {input.bed} -i {input.bam} > {output} 2> {log}"

rule rseqc_readdis:
    input:
        bam=rules.star_pass2.output.bam,
        bed=rules.gtf2bed.output.bed
    output:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04b_alignment_qc/rseqc/{smp}.readdistribution.txt"
    log:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04b_alignment_qc/rseqc/logs/rseqc_readdis/{smp}.log"
    conda:
        "../envs/rseqc.yaml"
    shell:
        "read_distribution.py -r {input.bed} -i {input.bam} > {output} 2> {log}"
        
rule rseqc_readgc:
    input:
        rules.star_pass2.output.bam
    output:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04b_alignment_qc/rseqc/{smp}.readgc.GC.xls"
    log:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04b_alignment_qc/rseqc/logs/rseqc_readgc/{smp}.log"
    params:
        prefix=lambda wildcards, output: output[0][:-7]
    conda:
        "../envs/rseqc.yaml"
    shell:
        "read_GC.py -i {input} -o {params.prefix} > {log} 2>&1"

#rule rseqc_readqual:
#    input:
#        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04a_alignment_results/star/{smp}/Aligned.out.bam"
#    output:
#        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04b_alignment_qc/rseqc/{smp}.readqual.heatmap.pdf",
#        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04b_alignment_qc/rseqc/{smp}.readqual.boxplot.pdf"
#    priority: 1
#    log:
#        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04b_alignment_qc/rseqc/logs/rseqc_readqual/{smp}.log"
#    params:
#        prefix="/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04b_alignment_qc/rseqc/{smp}.readqual"
#    conda:
#        "../envs/rseqc.yaml"
#    shell:
#        "read_quality.py -i {input} -o {params.prefix} > {log} 2>&1"


rule multiqc_rseqc:
    input:
        expand(rules.star_pass2.output.bam, smp=sample_id),
        expand(rules.rseqc_junction_annotation.output, smp=sample_id),
        expand(rules.rseqc_infer.output, smp=sample_id),
        expand(rules.rseqc_stat.output, smp=sample_id),
        expand(rules.rseqc_readdis.output, smp=sample_id),
        expand(rules.rseqc_readgc.output, smp=sample_id),
        expand(rules.rseqc_junction_annotation.log, smp=sample_id),
        expand(rules.star_pass2.output.log_final, smp=sample_id)
    output:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04b_alignment_qc/rseqc/rseqc_multiqc_report.html"
    log:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/04_alignment/04b_alignment_qc/rseqc/logs/multiqc.log"
    wrapper:
        "0.49.0/bio/multiqc"