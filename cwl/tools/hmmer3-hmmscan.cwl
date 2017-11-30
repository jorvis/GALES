#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: hmmscan

# hmmscan --acc --cut_ga --cpu 4 -o ../workflows/prodigal.annotation.faa.part1.hmm.raw ~/Dropbox/igs/databases/coding_hmm.lib.bin ../workflows/prodigal.annotation.faa.part1

requirements:
- class: InlineJavascriptRequirement

hints:
- class: DockerRequirement
  dockerPull: jorvis/gales-gce

inputs:
  query_file:
    type: File
    inputBinding:
      position: 6
  cutoff_gathering:
    type: boolean
    inputBinding:
      position: 2
      prefix: --cut_ga
  output_file:
    type: string
    inputBinding:
      position: 4
      prefix: -o
      separate: true
  thread_count:
    type: int
    inputBinding:
      position: 3
      prefix: --cpu
      separate: true
  use_accessions:
    type: boolean
    inputBinding:
      position: 1
      prefix: --acc
  database_file:
    type: File
    inputBinding:
      position: 5
outputs:
  output_base:
    type: File
    outputBinding:
      glob: $(inputs.output_file)

