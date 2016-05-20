#!/usr/bin/env cwl-runner

cwlVersion: "cwl:draft-3"

class: CommandLineTool
baseCommand: write_attributor_config.py

hints:
  - class: DockerRequirement
    dockerPull: jorvis/community-prok-pipeline

inputs:
  - id: template
    type: string
    inputBinding:
      prefix: --template
      separate: true
      position: 1
  - id: output_file
    type: string
    inputBinding:
      position: 2
      prefix: --output_file
      separate: true
  - id: hmm_files
    type:
      type: array
      items: File
    inputBinding:
      position: 3
      prefix: --hmm_files
      separate: true
      itemSeparator: ","
  - id: m8_files
    type:
      type: array
      items: File
    inputBinding:
      position: 4
      prefix: --m8_files
      separate: true
      itemSeparator: ","  
  - id: polypeptide_fasta
    type: File
    inputBinding:
      prefix: --polypeptide_fasta
      separate: true
      position: 5
  - id: gff3
    type: File
    inputBinding:
      prefix: --gff3
      separate: true
      position: 6

outputs:
  - id: output_config
    type: File
    outputBinding:
      glob: $(inputs.output_file)
