#!/usr/bin/env cwl-runner

cwlVersion: "cwl:draft-3"

class: CommandLineTool

baseCommand: write_fasta_from_gff.py

hints:
  - class: DockerRequirement
    dockerPull: community-prok-pipeline

inputs:
  - id: input_file
    type: File
    inputBinding:
      prefix: --input_file
      separate: true
      position: 1
  - id: output_file
    type: string
    inputBinding:
      position: 2
      prefix: --output_file
      separate: true
  - id: type
    type: string
    inputBinding:
      position: 3
      prefix: --type
      separate: true
  - id: fasta
    type: File
    inputBinding:
      position: 4
      prefix: --fasta
      separate: true
outputs:
  - id: protein_fasta
    type: File
    outputBinding:
      glob: $(inputs.output_file)

