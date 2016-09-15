#!/usr/bin/env cwl-runner

cwlVersion: "cwl:draft-3"

class: CommandLineTool
baseCommand: attributor

requirements:
  - class: InlineJavascriptRequirement
  - class: CreateFileRequirement
    fileDef:
      - filename: attributor.config
        fileContent: |
            general:
              default_product_name: hypothetical protein
              allow_attributes_from_multiple_sources: No
              debugging_polypeptide_limit: 0
            indexes:
              coding_hmm_lib: $(inputs.polypeptide_fasta.secondaryFiles[0].path)
              uniprot_sprot: $(inputs.polypeptide_fasta.secondaryFiles[1].path)
            input:
              polypeptide_fasta: $(inputs.polypeptide_fasta.path)
              gff3: $(inputs.source_gff3.path)
            order:
              - coding_hmm_lib__equivalog
              - rapsearch2__sprot
              - tmhmm
            evidence:
              - label: coding_hmm_lib__equivalog
                type: HMMer3_htab
                path: ${
                  var r = "";
                  for (var i = 0; i < inputs.hmm_files.length; i++) {
                    if (i > 0) {
                    r += ",";
                   }
                    r += inputs.hmm_files[i].path.replace('file://','');
                  }
                  return r;
                }
                class: equivalog
                index: coding_hmm_lib
              - label: rapsearch2__sprot
                type: RAPSearch2_m8
                path: ${
                  var r = "";
                  for (var i = 0; i < inputs.m8_files.length; i++) {
                    if (i > 0) {
                    r += ",";
                   }
                    r += inputs.m8_files[i].path.replace('file://','');
                  }
                  return r;
                }
                class: trusted
                index: uniprot_sprot
                query_cov: 85%
                match_cov: 85%
                percent_identity_cutoff: 50%
              - label: tmhmm
                type: TMHMM
                product_name: Putative integral membrane protein
                min_helical_spans: 3
                path: ${
                  var r = "";
                  for (var i = 0; i < inputs.tmhmm_files.length; i++) {
                    if (i > 0) {
                    r += ",";
                   }
                    r += inputs.tmhmm_files[i].path.replace('file://','');
                  }
                  return r;
                }
                
hints:
# this will have to be prefixed with jorvis/ after placement on Docker
  - class: DockerRequirement
    dockerPull: jorvis/falcon-gce

inputs:
  - id: config_file
    type: string
    inputBinding:
      prefix: -c
      separate: true
      position: 1
  - id: output_base
    type: string
    inputBinding:
      position: 2
      prefix: -o
      separate: true
  - id: output_format
    type: string
    inputBinding:
      position: 3
      prefix: -f
      separate: true
  - id: polypeptide_fasta
    type: File
  - id: source_gff3
    type: File
  - id: hmm_files
    type:
      type: array
      items: File
  - id: m8_files
    type:
      type: array
      items: File
  - id: tmhmm_files
    type:
      type: array
      items: File


outputs:
  - id: output_files
    type: 
      type: array
      items: File
    outputBinding:
      glob: $(inputs.output_base + '*')

