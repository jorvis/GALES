#!/usr/bin/env cwl-runner

cwlVersion: "cwl:draft-3"

class: CommandLineTool

baseCommand: prodigal
# example command:
# prodigal -i ../../test_data/e_coli_k12_dh10b.fna -f gff -o annotation.gff -a annotation.faa

hints:
  - class: DockerRequirement
    # this will have to be prefixed with jorvis/ after placement on Docker
    dockerPull: community-prok-pipeline

inputs:
  - id: genomic_fasta
    type: File
    inputBinding:
      prefix: -i
      separate: true
      position: 1
  - id: output_format
    type: string
    inputBinding:
      position: 2
      prefix: -f
      separate: true
  - id: annotation_out
    type: string
    inputBinding:
      position: 3
      prefix: -o
      separate: true
  - id: protein_out
    type: string
    inputBinding:
      position: 4
      prefix: -a
      separate: true

outputs:
  - id: prodigal_annot_file
    type: File
    outputBinding:
      glob: $(inputs.annotation_out)
  - id: prodigal_protein_file
    type: File
    outputBinding:
      glob: $(inputs.protein_out)

