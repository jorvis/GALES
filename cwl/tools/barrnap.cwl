#!/usr/bin/env cwl-runner

cwlVersion: "cwl:draft-3"
class: CommandLineTool

baseCommand: barrnap

hints:
  - class: DockerRequirement
    dockerPull: jorvis/gales-gce

inputs:
  - id: genomic_fasta
    type: File
    inputBinding:
      position: 1

outputs:
  - id: gff_output
    type: File
    outputBinding:
      glob: 'barnapp.gff'

stdout: 'barnapp.gff'

