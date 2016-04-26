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
  # split_fasta
  - id: "fragmentation_count"
    type: int
    description: "How many files the input will be split into"
  - id: "out_dir"
    type: string
    description: "Location where split files will be written"
  # rapsearch2
  - id: "rapsearch2_database_file"
    type: string
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
  # HMMer3
  - id: "hmmscan_use_accessions"
    type: boolean
    description: ""
  - id: "hmmscan_cutoff_gathering"
    type: boolean
  - id: "hmmscan_database_file"
    type: string
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
    type: string
    description: ""
  - id: "raw2htab_output_htab"
    type: string
    description: ""
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

steps:
  - id: prodigal
    run: ../tools/cpp-prodigal.cwl
    inputs:
      - { id: "prodigal.genomic_fasta", source: "#source_fasta" }
      - { id: "prodigal.output_format", source: "#output_format" }
      - { id: "prodigal.annotation_out", source: "#initial_structural_prediction" }
      - { id: "prodigal.protein_out", source: "#initial_protein_out" }
    outputs:
      - { id: prodigal_annot_file }
      - { id: prodigal_protein_file }
  - id: split_multifasta
    run: ../tools/biocode-SplitFastaIntoEvenFiles.cwl
    inputs:
      - { id: "split_multifasta.file_to_split", source: "#prodigal/prodigal_protein_file" }
      - { id: "split_multifasta.file_count", source: "#fragmentation_count" }
      - { id: "split_multifasta.output_directory", source: "#out_dir" }
    outputs:
      - { id: fasta_files }
  - id: rapsearch2
    run: ../tools/cpp-rapsearch2.cwl
    inputs:
      - { id: "rapsearch2.database_file", source: "#rapsearch2_database_file" }
      - { id: "rapsearch2.query_file", source: "#split_multifasta/fasta_files" }
      - { id: "rapsearch2.output_file_base", source: "#rapsearch2_output_file_base" }
      - { id: "rapsearch2.thread_count", source: "#rapsearch2_threads"}
    scatter: "#rapsearch2/rapsearch2.query_file"
    outputs:
      - { id: "output_base" }
  - id: hmmscan
    run: ../tools/cpp-hmmer3-hmmscan.cwl
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
    run: ../tools/biocode-ConvertHmmscanToHtab.cwl
    inputs:
      - { id: "raw2htab.input_file", source: "#hmmscan/output_base" }
      - { id: "raw2htab.output_htab", source: "#raw2htab_output_htab" }
      - { id: "raw2htab.mldbm_file", source: "#raw2htab_mldbm_file" }
    scatter: "#raw2htab/raw2htab.input_file"
    outputs:
      - { id: "htab_file" }

