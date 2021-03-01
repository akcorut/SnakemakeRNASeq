rule salmon_meta:
    input:
        ref= REFERENCE,
        tcp= TRANSCRIPTS
    output:
        gent= "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/06_alignment_free/06a_salmon/decoy/gentrome.fa",
        decoy= "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/06_alignment_free/06a_salmon/decoy/decoys.txt",
        bak="/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/06_alignment_free/06a_salmon/decoy/decoys.txt.bak"
    conda:
        "../envs/salmon.yaml"
    threads:8
    shell:
        """
        grep "^>" {input.ref} | cut -d " " -f 1 > {output.decoy}
        sed -i.bak -e 's/>//g' {output.decoy}
        cat {input.tcp} {input.ref} > {output.gent}
        """

rule salmon_index:
    input:
        gent= rules.salmon_meta.output.gent,
        decoy= rules.salmon_meta.output.decoy
    output:
        directory("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/06_alignment_free/06a_salmon/index")
    log:
        "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/06_alignment_free/06a_salmon/logs/index.log"
    conda:
        "../envs/salmon.yaml"
    threads:24
    shell:
        """
        salmon index -p {threads} -t {input.gent} -d {input.decoy} -i {output} &> {log}
        """

if config["salmon"]["mapping_mode"]:
    rule salmon_quant_mapping:
        input:
            r1=GetClean(0),
            r2=GetClean(1),
            index = rules.salmon_index.output
        output:
            directory("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/06_alignment_free/06a_salmon/quant/{smp}"),
            mappings="/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/06_alignment_free/06a_salmon/mappings/{smp}_salmon_mappings"
        log:
    		"/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/06_alignment_free/06a_salmon/logs/{smp}.salmon.log"
        conda:
            "../envs/salmon.yaml"
        threads:24
        shell:
            """
            salmon quant -i {input.index} -l A -1 {input.r1} -2 {input.r2} -o {output} --validateMappings --gcBias --seqBias --writeUnmappedNames --writeMappings={output.mappings} -p {threads} --numBootstraps 100
            """
    
    rule multiqc_salmon:
        input:
            expand(rules.salmon_quant_mapping.output, smp=sample_id)
        output:
            "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/06_alignment_free/06a_salmon/salmon_multiqc.html"
        log:
            "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/06_alignment_free/06a_salmon/logs/multiqc.log"
        wrapper:
            "0.49.0/bio/multiqc"

if config["salmon"]["alignment_mode"]:
    rule make_transcript:
        input:
            ref= REFERENCE,
            gtf= rules.gff3_to_gtf.output.gtf
        output:
            "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/salmon_align/transcript/arahy_transcripts.fa"
        conda:
            "../envs/gffread.yaml"
        shell:
            '''
            gffread -w {output} -g {input.ref} {input.gtf}
            '''

    rule salmon_quant_alignment:
        input:
            bam= rules.star_pass2.output.tcp_bam,
            tcp = rules.make_transcript.output,
            gtf= rules.gff3_to_gtf.output.gtf,
        output:
            directory("/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/salmon_align/quant/{smp}_salmon_quant_align")
        log:
    		"/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/salmon_align/logs/{smp}.salmon_align.log"
        conda:
            "../envs/salmon.yaml"
        threads:24
        priority:2
        shell:
            '''
            salmon quant -t {input.tcp} -l A -a {input.bam} -o {output} --gcBias --seqBias --writeUnmappedNames -p {threads} -g {input.gtf} --numBootstraps 100
            '''



if config["salmon"]["alignment_mode"]:
    rule multiqc_salmon_align:
        input:
            expand(rules.salmon_quant_alignment.output, smp=sample_id)
        output:
            "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/salmon_align/salmon_align_multiqc.html"
        log:
            "/scratch/ac32082/02.PeanutRNASeq/01.analysis/peanut_rna_seq_analysis/results/salmon_align/logs/multiqc.log"
        wrapper:
            "0.47.0/bio/multiqc"