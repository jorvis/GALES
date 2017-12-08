#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

baseCommand: merge_predicted_gff3.py

hints:
- class: DockerRequirement
  dockerPull: jorvis/biocode

inputs:
  barrnap_gff:
    type: File
    inputBinding:
      position: 3
      prefix: -b
      separate: true
  model_gff:
    type: File
    inputBinding:
      prefix: -m
      separate: true
      position: 1
  aragorn_out:
    type: File
    inputBinding:
      position: 4
      prefix: -a
      separate: true
  output_gff:
    type: string
    inputBinding:
      position: 2
      prefix: -o
      separate: true
outputs:
  output_file:
    type: File
    outputBinding:
      glob: $(inputs.output_gff)


