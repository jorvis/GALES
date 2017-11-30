#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

baseCommand: prodigal
# example command:
# prodigal -i ../../test_data/e_coli_k12_dh10b.fna -f gff -o annotation.gff -a annotation.faa

hints:
- class: DockerRequirement
    # this will have to be prefixed with jorvis/ after placement on Docker
  dockerPull: jorvis/gales-gce

inputs:
  output_format:
    type: string
    inputBinding:
      position: 2
      prefix: -f
      separate: true
  protein_out:
    type: string
    inputBinding:
      position: 4
      prefix: -a
      separate: true

  genomic_fasta:
    type: File
    inputBinding:
      prefix: -i
      separate: true
      position: 1
  annotation_out:
    type: string
    inputBinding:
      position: 3
      prefix: -o
      separate: true
outputs:
  prodigal_annot_file:
    type: File
    outputBinding:
      glob: $(inputs.annotation_out)
  prodigal_protein_file:
    type: File
    outputBinding:
      glob: $(inputs.protein_out)


