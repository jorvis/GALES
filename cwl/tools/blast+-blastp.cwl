#!/usr/bin/env cwl-runner

cwlVersion: cwl:draft-3
class: CommandLineTool
baseCommand: blastp

inputs:
  - id: database_name
    type: string
    inputBinding:
      prefix: -db
      separate: true
      position: 1
  - id: query
    type: File
    inputBinding:
      position: 2
      prefix: -query
      separate: true
  - id: out
    type: string
    inputBinding:
      position: 3
      prefix: -out
      separate: true
  - id: evalue
    type: ["null", float]
    inputBinding:
      position: 4
      prefix: -evalue
      separate: true
  - id: outfmt
    type: int
    inputBinding:
      position: 5
      prefix: -outfmt
      separate: true
outputs:
  - id: blast_tab_file
    type: File
    outputBinding:
      glob: $(inputs.out)
