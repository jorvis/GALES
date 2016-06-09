#!/usr/bin/env cwl-runner

cwlVersion: "cwl:draft-3"
class: CommandLineTool

baseCommand: barrnap

hints:
  - class: DockerRequirement
    dockerPull: jorvis/community-prok-pipeline

inputs:
  - id: genomic_fasta
    type: File
    inputBinding:
      position: 1

outputs:
  - id: prodigal_protein_file
    type: File
    outputBinding:
      glob: 'barnapp.gff'

stdout: 'barnapp.gff'

