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
  # blastp
  - id: "blast_db"
    type: string
    description: "Base name of formatted BLAST+ database"
  - id: blast_out
    type: string
    description: "Output BLAST file to write"
  - id: blast_outfmt
    type: int
    description: "Format of BLAST output files"
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
  - id: blast_tab_files
    type:
      type: array
      items: File
    source: "#blastp/blast_tab_file"
  - id: rapsearch2_m8_files
    type:
      type: array
      items: File
    source: "#rapsearch2/output_base"

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
  - id: blastp
    run: ../tools/blast+-blastp.cwl
    inputs:
      - { id: "blastp.database_name", source: "#blast_db" }
      - { id: "blastp.query", source: "#split_multifasta/fasta_files" }
      - { id: "blastp.out", source: "#blast_out" }
      - { id: "blastp.outfmt", source: "#blast_outfmt" }
    scatter: "#blastp/blastp.query"
    outputs:
      - { id: blast_tab_file }
  - id: rapsearch2
    run: ../tools/cpp-rapsearch2.cwl
    inputs:
      - { id: "rapsearch2.database_file", source: "#rapsearch2_database_file" }
      - { id: "rapsearch2.query_file", source: "#split_multifasta/fasta_files" }
      - { id: "rapsearch2.output_file_base", source: "#rapsearch2_output_file_base" }
    scatter: "#rapsearch2/rapsearch2.query_file"
    outputs:
      - { id: "output_base" }

      

