#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

baseCommand: write_fasta_from_gff.py

hints:
- class: DockerRequirement
  dockerPull: jorvis/biocode

inputs:
  input_file:
    type: File
    inputBinding:
      prefix: --input_file
      separate: true
      position: 1
  type:
    type: string
    inputBinding:
      position: 3
      prefix: --type
      separate: true
  output_file:
    type: string
    inputBinding:
      position: 2
      prefix: --output_file
      separate: true
  fasta:
    type: File
    inputBinding:
      position: 4
      prefix: --fasta
      separate: true
  feature_type:
    type: string
    inputBinding:
      position: 5
      prefix: --feature_type
      separate: true
outputs:
  protein_fasta:
    type: File
    outputBinding:
      glob: $(inputs.output_file)


