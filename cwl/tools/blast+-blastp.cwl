#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: blastp

inputs:
  query:
    type: File
    inputBinding:
      position: 2
      prefix: -query
      separate: true
  out:
    type: string
    inputBinding:
      position: 3
      prefix: -out
      separate: true
  database_name:
    type: string
    inputBinding:
      prefix: -db
      separate: true
      position: 1
  outfmt:
    type: int
    inputBinding:
      position: 5
      prefix: -outfmt
      separate: true
  evalue:
    type: float?
    inputBinding:
      position: 4
      prefix: -evalue
      separate: true
outputs:
  blast_tab_file:
    type: File
    outputBinding:
      glob: $(inputs.out)

