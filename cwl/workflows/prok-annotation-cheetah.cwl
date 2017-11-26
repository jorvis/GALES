#!/usr/bin/env cwl-runner

# http://www.commonwl.org/draft-3/Workflow.html#Parameter_references
# http://www.commonwl.org/draft-3/CommandLineTool.html#Runtime_environment
# http://www.commonwl.org/draft-3/CommandLineTool.html

cwlVersion: "cwl:draft-3"

class: Workflow

requirements:
  - class: ScatterFeatureRequirement

inputs:
  # Prodigal
  - id: "source_fasta"
    type: File
    description: "Starting protein multi-FASTA file"
  - id: "output_format"
    type: string
    description: "Prodigal prediction output format"
  - id: "initial_structural_prediction"
    type: string
    description: "Prodigal structural prediction file"
  - id: "initial_protein_out"
    type: string
    description: "Prodigal polypeptide FASTA prediction file"
  # Convert prodigal
  - id: "prodigal2gff3_input_file"
    type: File
    description: ""
  - id: "prodigal2gff3_output_file"
    type: string
    description: ""
  # Write prodigal FASTA (with GFF-matching IDs)
  - id: "prodigal2fasta_input_file"
    type: File
    description: ""
  - id: "prodigal2fasta_output_file"
    type: string
    description: ""
  - id: "prodigal2fasta_type"
    type: string
    description: ""
  - id: "prodigal2fasta_fasta"
    type: File
    description: "Genomic FASTA"
  - id: "prodigal2fasta_feature_type"
    type: string
    description: ""
  # split_fasta
  - id: "fragmentation_count"
    type: int
    description: "How many files the input will be split into"
  - id: "out_dir"
    type: string
    description: "Location where split files will be written"
  # rapsearch2
  - id: "rapsearch2_database_file"
    type: File
    description: ""
  - id: "rapsearch2_query_file"
    type: File
    description: ""
  - id: "rapsearch2_output_file_base"
    type: string
    description: ""
  - id: "rapsearch2_threads"
    type: int
    description: ""
  - id: "rapsearch2_one_line_desc_count"
    type: int
    description: "Number of matches to return"
  # HMMer3
  - id: "hmmscan_use_accessions"
    type: boolean
    description: ""
  - id: "hmmscan_cutoff_gathering"
    type: boolean
  - id: "hmmscan_database_file"
    type: File
    description: ""
  - id: "hmmscan_query_file"
    type: File
    description: ""
  - id: "hmmscan_output_file"
    type: string
    description: ""
  - id: "hmmscan_threads"
    type: int
    description: ""
  # Convert HMMer3 to HTAB
  - id: "raw2htab_input_file"
    type: File
    description: ""
  - id: "raw2htab_mldbm_file"
    type: File
    description: ""
  - id: "raw2htab_output_htab"
    type: string
    description: ""
  # TMHMM
  - id: "tmhmm_input_file"
    type: File
  # Attributor
  - id: attributor_config_file
    type: string
  - id: attributor_output_base
    type: string
    description: ""
  - id: attributor_output_format
    type: string
    description: ""
  - id: attributor_hmm_attribute_lookup_file
    type: File
  - id: attributor_blast_attribute_lookup_file
    type: File
  - id: attributor_polypeptide_fasta
    type: File
  - id: attributor_source_gff3
    type: File
outputs:
  - id: fasta_files
    type:
      type: array
      items: File
    source: "#split_multifasta/fasta_files"
  - id: prodigal_annot_file
    type: File
    source: "#prodigal/prodigal_annot_file"
  - id: prodigal_protein_file
    type: File
    source: "#prodigal/prodigal_protein_file"
  - id: prodigal_gff3
    type: File
    source: "#prodigal2gff3/output_gff3"
  - id: prodigal_protein_fasta
    type: File
    source: "#prodigal2fasta/protein_fasta"
  - id: rapsearch2_m8_files
    type:
      type: array
      items: File
    source: "#rapsearch2/output_base"
  - id: hmmscan_raw_files
    type:
      type: array
      items: File
    source: "#hmmscan/output_base"
  - id: hmmscan_htab_files
    type:
      type: array
      items: File
    source: "#raw2htab/htab_file"
  - id: tmhmm_raw_files
    type:
      type: array
      items: File
    source: "#tmhmm/tmhmm_out"
  - id: attributor_files
    type:
      type: array
      items: File
    source: "#attributor/output_files"
  - id: attributor_output_config
    type: File
    source: "#attributor/the_config"


steps:
  - id: prodigal
    run: {{cwl_tools_dir}}/cpp-prodigal-gce.cwl
    inputs:
      - { id: "prodigal.genomic_fasta", source: "#source_fasta" }
      - { id: "prodigal.output_format", source: "#output_format" }
      - { id: "prodigal.annotation_out", source: "#initial_structural_prediction" }
      - { id: "prodigal.protein_out", source: "#initial_protein_out" }
    outputs:
      - { id: prodigal_annot_file }
      - { id: prodigal_protein_file }
  - id: prodigal2gff3
    run: {{cwl_tools_dir}}/biocode-ConvertProdigalToGFF3.cwl
    inputs:
      - { id: "prodigal2gff3.input_file", source: "#prodigal/prodigal_annot_file" }
      - { id: "prodigal2gff3.output_file", source: "#prodigal2gff3_output_file" }
    outputs:
      - { id: "output_gff3" }
  - id: prodigal2fasta
    run: {{cwl_tools_dir}}/biocode-WriteFastaFromGFF.cwl
    inputs:
      - { id: "prodigal2fasta.input_file", source: "#prodigal2gff3/output_gff3" }
      - { id: "prodigal2fasta.output_file", source: "#prodigal2fasta_output_file" }
      - { id: "prodigal2fasta.type", source: "#prodigal2fasta_type" }
      - { id: "prodigal2fasta.fasta", source: "#source_fasta" }
      - { id: "prodigal2fasta.feature_type", source: "#prodigal2fasta_feature_type" }
    outputs:
      - { id: "protein_fasta" }
  - id: split_multifasta
    run: {{cwl_tools_dir}}/biocode-SplitFastaIntoEvenFiles.cwl
    inputs:
      - { id: "split_multifasta.file_to_split", source: "#prodigal2fasta/protein_fasta" }
      - { id: "split_multifasta.file_count", source: "#fragmentation_count" }
      - { id: "split_multifasta.output_directory", source: "#out_dir" }
    outputs:
      - { id: fasta_files }
  - id: rapsearch2
    run: {{cwl_tools_dir}}/cpp-rapsearch2-gce.cwl
    inputs:
      - { id: "rapsearch2.database_file", source: "#rapsearch2_database_file" }
      - { id: "rapsearch2.query_file", source: "#split_multifasta/fasta_files" }
      - { id: "rapsearch2.output_file_base", source: "#rapsearch2_output_file_base" }
      - { id: "rapsearch2.thread_count", source: "#rapsearch2_threads"}
      - { id: "rapsearch2.one_line_desc_count", source: "#rapsearch2_one_line_desc_count"}
    scatter: "#rapsearch2/rapsearch2.query_file"
    outputs:
      - { id: "output_base" }
  - id: hmmscan
    run: {{cwl_tools_dir}}/cpp-hmmer3-hmmscan-gce.cwl
    inputs:
      - { id: "hmmscan.cutoff_gathering", source: "#hmmscan_cutoff_gathering" }
      - { id: "hmmscan.use_accessions", source: "#hmmscan_use_accessions" }
      - { id: "hmmscan.database_file", source: "#hmmscan_database_file" }
      - { id: "hmmscan.query_file", source: "#split_multifasta/fasta_files" }
      - { id: "hmmscan.output_file", source: "#hmmscan_output_file" }
      - { id: "hmmscan.thread_count", source: "#hmmscan_threads"}
    scatter: "#hmmscan/hmmscan.query_file"
    outputs:
      - { id: "output_base" }
  - id: raw2htab
    run: {{cwl_tools_dir}}/biocode-ConvertHmmscanToHtab.cwl
    inputs:
      - { id: "raw2htab.input_file", source: "#hmmscan/output_base" }
      - { id: "raw2htab.output_htab", source: "#raw2htab_output_htab" }
      - { id: "raw2htab.mldbm_file", source: "#raw2htab_mldbm_file" }
    scatter: "#raw2htab/raw2htab.input_file"
    outputs:
      - { id: "htab_file" }
  - id: tmhmm
    run: {{cwl_tools_dir}}/cpp-tmhmm-gce.cwl
    inputs:
      - { id: "tmhmm.query_file", source: "#split_multifasta/fasta_files" }
    scatter: "#tmhmm/tmhmm.query_file"
    outputs:
      - { id: "tmhmm_out" }
  - id: attributor
    run: {{cwl_tools_dir}}/attributor-prok-cheetah.cwl
    inputs:
      - { id: "attributor.config_file", source: "#attributor_config_file" }
      - { id: "attributor.output_base", source: "#attributor_output_base" }
      - { id: "attributor.output_format", source: "#attributor_output_format" }
      - { id: "attributor.hmm_attribute_lookup_file", source: "#attributor_hmm_attribute_lookup_file" }
      - { id: "attributor.blast_attribute_lookup_file", source: "#attributor_blast_attribute_lookup_file" }
      - { id: "attributor.hmm_files", source: "#raw2htab/htab_file" }
      - { id: "attributor.polypeptide_fasta", source: "#prodigal2fasta/protein_fasta" }
      - { id: "attributor.source_gff3", source: "#prodigal2gff3/output_gff3" }
      - { id: "attributor.m8_files", source: "#rapsearch2/output_base" }
      - { id: "attributor.tmhmm_files", source: "#tmhmm/tmhmm_out" }
    outputs:
      - { id: "output_files" }
      - { id: "the_config" }


