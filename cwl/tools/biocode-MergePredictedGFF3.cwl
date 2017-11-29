#!/usr/bin/env cwl-runner

cwlVersion: "cwl:draft-3"

class: CommandLineTool

baseCommand: merge_predicted_gff3.py

hints:
  - class: DockerRequirement
    dockerPull: jorvis/biocode

inputs:
  - id: model_gff
    type: File
    inputBinding:
      prefix: -m
      separate: true
      position: 1
  - id: output_gff
    type: File
    inputBinding:
      position: 2
      prefix: -o
      separate: true
  - id: barrnap_gff
    type: File
    inputBinding:
      position: 3
      prefix: -b
      separate: true
  - id: aragorn_out
    type: File
    inputBinding:
      position: 4
      prefix: -a
      separate: true
outputs:
  - id: output_file
    type: File
    outputBinding:
      glob: $(inputs.output_gff)

