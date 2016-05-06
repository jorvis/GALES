#!/usr/bin/env cwl-runner

cwlVersion: "cwl:draft-3"

class: CommandLineTool
baseCommand: convert_fasta_contigs_to_gff3.py

hints:
  - class: DockerRequirement
    dockerPull: community-prok-pipeline

inputs:
  - id: input_fasta
    type: File
    inputBinding:
      prefix: --input_fasta
      separate: true
      position: 1
  - id: output_gff3
    type: string
    inputBinding:
      position: 2
      prefix: --output_gff3
      separate: true
  - id: source
    type: string
    inputBinding:
      position: 3
      prefix: --source
      separate: true
outputs:
  - id: gff3_file
    type: File
    outputBinding:
      glob: $(inputs.output_gff3)

