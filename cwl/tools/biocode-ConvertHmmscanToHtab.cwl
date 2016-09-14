#!/usr/bin/env cwl-runner

cwlVersion: "cwl:draft-3"

class: CommandLineTool

baseCommand: convert_hmmscan_to_htab.pl

hints:
  - class: DockerRequirement
    dockerPull: jorvis/biocode

inputs:
  - id: input_file
    type: File
    inputBinding:
      prefix: --input_file
      separate: true
      position: 1
  - id: output_htab
    type: string
    inputBinding:
      position: 2
      prefix: --output_htab
      separate: true
  - id: mldbm_file
    type: string
    inputBinding:
      position: 3
      prefix: --mldbm_file
      separate: true
outputs:
  - id: htab_file
    type: File
    outputBinding:
      glob: $(inputs.output_htab)

