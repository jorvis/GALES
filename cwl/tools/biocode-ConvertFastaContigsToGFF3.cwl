#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: convert_fasta_contigs_to_gff3.py

hints:
- class: DockerRequirement
  dockerPull: jorvis/community-prok-pipeline

inputs:
  input_fasta:
    type: File
    inputBinding:
      prefix: --input_fasta
      separate: true
      position: 1
  output_gff3:
    type: string
    inputBinding:
      position: 2
      prefix: --output_gff3
      separate: true
  source:
    type: string
    inputBinding:
      position: 3
      prefix: --source
      separate: true
outputs:
  gff3_file:
    type: File
    outputBinding:
      glob: $(inputs.output_gff3)


