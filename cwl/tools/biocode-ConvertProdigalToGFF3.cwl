#!/usr/bin/env cwl-runner

cwlVersion: "cwl:draft-3"

class: CommandLineTool

baseCommand: convert_prodigal_to_gff3.py

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
outputs:
  - id: output_gff3
    type: File
    outputBinding:
      glob: $(inputs.output_file)

