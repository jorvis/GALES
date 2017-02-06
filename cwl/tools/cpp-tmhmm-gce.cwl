#!/usr/bin/env cwl-runner

cwlVersion: cwl:draft-3
class: CommandLineTool
baseCommand: tmhmm

requirements:
- class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: jorvis/gales-gce

inputs:
  - id: query_file
    type: File
    inputBinding:
      position: 1
outputs:
  - id: tmhmm_out
    type: File
    outputBinding:
      glob: $(inputs.query_file.path.split('/').slice(-1)[0]  + '.tmhmm.raw')

# pattern method taken from: https://github.com/common-workflow-language/common-workflow-language/issues/130
stdout: $(inputs.query_file.path.split('/').slice(-1)[0] + '.tmhmm.raw')
