#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: tmhmm

requirements:
- class: InlineJavascriptRequirement

hints:
- class: DockerRequirement
  dockerPull: jorvis/gales-gce

inputs:
  query_file:
    type: File
    inputBinding:
      position: 1
outputs:
  tmhmm_out:
    type: File
    outputBinding:
      glob: $(inputs.query_file.path.split('/').slice(-1)[0]  + '.tmhmm.raw')

stdout: $(inputs.query_file.path.split('/').slice(-1)[0] + '.tmhmm.raw')

