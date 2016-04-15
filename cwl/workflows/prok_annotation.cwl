#!/usr/bin/env cwl-runner

# http://www.commonwl.org/draft-3/Workflow.html#Parameter_references
# http://www.commonwl.org/draft-3/CommandLineTool.html#Runtime_environment
# http://www.commonwl.org/draft-3/CommandLineTool.html

cwlVersion: "cwl:draft-3"

class: Workflow

requirements:
  - class: ScatterFeatureRequirement

inputs:
  - id: "source_fasta"
    type: File
    description: "Starting protein multi-FASTA file"
  - id: "fragmentation_count"
    type: int
    description: "How many files the input will be split into"
  - id: "out_dir"
    type: string
    description: "Location where split files will be written"
  - id: "blast_db"
    type: string
    description: "Base name of formatted BLAST+ database"
  - id: blast_out
    type: string
    description: "Output BLAST file to write"
  - id: blast_outfmt
    type: int
    description: "Format of BLAST output files"

outputs:
  - id: fasta_files
    type:
      type: array
      items: File
    source: "#split_multifasta/fasta_files"

steps:
  - id: split_multifasta
    run: ../tools/biocode-SplitFastaIntoEvenFiles.cwl
    inputs:
      - { id: "split_multifasta.file_to_split", source: "#source_fasta" }
      - { id: "split_multifasta.file_count", source: "#fragmentation_count" }
      - { id: "split_multifasta.output_directory", source: "#out_dir" }
    outputs:
      - { id: fasta_files }
  - id: blastp
    run: ../tools/blast+-blastp.cwl
    inputs:
      - { id: "blastp.database_name", source: "#blast_db" }
      - { id: "blastp.query", source: "#split_multifasta/fasta_files" }
      - { id: "blastp.out", source: "#blast_out" }
      - { id: "blastp.outfmt", source: "#blast_outfmt" }
    scatter: "#blastp/blastp.query"
    outputs: []

      

