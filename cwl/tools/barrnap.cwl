#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

baseCommand: barrnap

hints:
- class: DockerRequirement
  dockerPull: jorvis/gales-gce

inputs:
  genomic_fasta:
    type: File
    inputBinding:
      position: 1

outputs:
  barrnap_gff_output:
    type: File
    outputBinding:
      glob: barnapp.gff
stdout: barnapp.gff

