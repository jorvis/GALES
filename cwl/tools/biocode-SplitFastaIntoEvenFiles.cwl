#!/usr/bin/env cwl-runner

cwlVersion: "cwl:draft-3"

class: CommandLineTool

baseCommand: split_fasta_into_even_files.py

hints:
  - class: DockerRequirement
    dockerPull: jorvis/biocode

inputs:
  - id: file_to_split
    type: File
    inputBinding:
      prefix: --input_file
      separate: true
      position: 1
  - id: file_count
    type: int
    inputBinding:
      position: 2
      prefix: --file_count
      separate: true
  - id: output_directory
    type: string
    inputBinding:
      position: 3
      prefix: --output_directory
      separate: true

outputs:
  - id: fasta_files
    type:
      type: array
      items: File
    outputBinding:
      glob: "*.part*"
