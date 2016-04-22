#!/usr/bin/env cwl-runner

cwlVersion: cwl:draft-3
class: CommandLineTool
baseCommand: hmmscan

# hmmscan --acc --cut_ga --cpu 4 -o ../workflows/prodigal.annotation.faa.part1.hmm.raw ~/Dropbox/igs/databases/coding_hmm.lib.bin ../workflows/prodigal.annotation.faa.part1

requirements:
- class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    # this will have to be prefixed with jorvis/ after placement on Docker
    dockerPull: community-prok-pipeline

inputs:
  - id: use_accessions
    type: boolean
    inputBinding:
      position: 1
      prefix: --acc
  - id: cutoff_gathering
    type: boolean
    inputBinding:
      position: 2
      prefix: --cut_ga
  - id: thread_count
    type: int
    inputBinding:
      position: 3
      prefix: --cpu
      separate: true
  - id: output_file
    type: string
    inputBinding:
      position: 4
      prefix: -o
      separate: true
  - id: database_file
    type: string
    inputBinding:
      position: 5
  - id: query_file
    type: File
    inputBinding:
      position: 6
outputs:
  - id: output_base
    type: File
    outputBinding:
      glob: $(inputs.output_file)
