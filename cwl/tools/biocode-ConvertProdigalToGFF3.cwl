#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

baseCommand: convert_prodigal_to_gff3.py

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
  output_file:
    type: string
    inputBinding:
      position: 2
      prefix: --output_file
      separate: true
outputs:
  output_gff3:
    type: File
    outputBinding:
      glob: $(inputs.output_file)


