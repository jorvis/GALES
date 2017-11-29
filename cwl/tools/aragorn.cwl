#!/usr/bin/env cwl-runner

cwlVersion: "cwl:draft-3"
class: CommandLineTool

baseCommand: aragorn

hints:
  - class: DockerRequirement
    dockerPull: jorvis/gales-gce

inputs:
  - id: aragorn_format
    type: boolean
    inputBinding:
      position: 1
      prefix: -w
  - id: genomic_fasta
    type: File
    inputBinding:
      position: 2

outputs:
  - id: aragorn_raw_output
    type: File
    outputBinding:
      glob: 'aragorn.out'

stdout: 'aragorn.out'

