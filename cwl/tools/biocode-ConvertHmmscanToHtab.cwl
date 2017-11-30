#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

baseCommand: convert_hmmscan_to_htab.pl

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
  mldbm_file:
    type: File
    inputBinding:
      position: 3
      prefix: --mldbm_file
      separate: true
  output_htab:
    type: string
    inputBinding:
      position: 2
      prefix: --output_htab
      separate: true
outputs:
  htab_file:
    type: File
    outputBinding:
      glob: $(inputs.output_htab)


