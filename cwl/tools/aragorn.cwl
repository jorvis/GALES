#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

baseCommand: aragorn

hints:
- class: DockerRequirement
  dockerPull: jorvis/gales-gce

inputs:
  genomic_fasta:
    type: File
    inputBinding:
      position: 2

  aragorn_format:
    type: boolean
    inputBinding:
      position: 1
      prefix: -w
outputs:
  aragorn_raw_output:
    type: File
    outputBinding:
      glob: aragorn.out
stdout: aragorn.out

