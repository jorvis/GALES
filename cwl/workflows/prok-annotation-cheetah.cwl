#!/usr/bin/env cwl-runner

# http://www.commonwl.org/draft-3/Workflow.html#Parameter_references
# http://www.commonwl.org/draft-3/CommandLineTool.html#Runtime_environment
# http://www.commonwl.org/draft-3/CommandLineTool.html

cwlVersion: v1.0
class: Workflow

requirements:
- class: ScatterFeatureRequirement

inputs:
  # Barrnap
  - id: barrnap_genomic_fasta
    type: File
    doc: Input genomic FASTA file
  
  # Aragorn
  - id: aragorn_format
    type: boolean
  
  # Prodigal
  - id: source_fasta
    type: File
    doc: Starting protein multi-FASTA file
  - id: output_format
    type: string
    doc: Prodigal prediction output format
  - id: initial_structural_prediction
    type: string
    doc: Prodigal structural prediction file
  - id: initial_protein_out
    type: string
    doc: Prodigal polypeptide FASTA prediction file
  
  # Convert prodigal
  - id: prodigal2gff3_input_file
    type: File
    doc: ''
  - id: prodigal2gff3_output_file
    type: string
    doc: ''
  
  # Write prodigal FASTA (with GFF-matching IDs)
  - id: prodigal2fasta_input_file
    type: File
    doc: ''
  - id: prodigal2fasta_output_file
    type: string
    doc: ''
  - id: prodigal2fasta_type
    type: string
    doc: ''
  - id: prodigal2fasta_fasta
    type: File
    doc: Genomic FASTA
  - id: prodigal2fasta_feature_type
    type: string
    doc: ''
  
  # split_fasta
  - id: fragmentation_count
    type: int
    doc: How many files the input will be split into
  - id: out_dir
    type: string
    doc: Location where split files will be written
  
  # rapsearch2
  - id: rapsearch2_database_file
    type: File
    doc: ''
  - id: rapsearch2_query_file
    type: File
    doc: ''
  - id: rapsearch2_output_file_base
    type: string
    doc: ''
  - id: rapsearch2_threads
    type: int
    doc: ''
  - id: rapsearch2_one_line_desc_count
    type: int
    doc: Number of matches to return
  
  # HMMer3
  - id: hmmscan_use_accessions
    type: boolean
    doc: ''
  - id: hmmscan_cutoff_gathering
    type: boolean
  - id: hmmscan_database_file
    type: File
    doc: ''
  - id: hmmscan_query_file
    type: File
    doc: ''
  - id: hmmscan_output_file
    type: string
    doc: ''
  - id: hmmscan_threads
    type: int
    doc: ''
  
  # Convert HMMer3 to HTAB
  - id: raw2htab_input_file
    type: File
    doc: ''
  - id: raw2htab_mldbm_file
    type: File
    doc: ''
  - id: raw2htab_output_htab
    type: string
    doc: ''
  
  # TMHMM
  - id: tmhmm_input_file
    type: File
  
  # Attributor
  - id: attributor_config_file
    type: string
  - id: attributor_output_base
    type: string
    doc: ''
  - id: attributor_output_format
    type: string
    doc: ''
  - id: attributor_hmm_attribute_lookup_file
    type: File
  - id: attributor_blast_attribute_lookup_file
    type: File
  - id: attributor_polypeptide_fasta
    type: File
  - id: attributor_source_gff3
    type: File
outputs:
- id: fasta_files
  type:
    type: array
    items: File
  outputSource: '#split_multifasta/fasta_files'
- id: barrnap_gff_output
  type: File
  outputSource: '#barrnap/barrnap_gff_output'
- id: aragorn_raw_output
  type: File
  outputSource: '#aragorn/aragorn_raw_output'
- id: prodigal_annot_file
  type: File
  outputSource: '#prodigal/prodigal_annot_file'
- id: prodigal_protein_file
  type: File
  outputSource: '#prodigal/prodigal_protein_file'
- id: prodigal_gff3
  type: File
  outputSource: '#prodigal2gff3/output_gff3'
- id: prodigal_protein_fasta
  type: File
  outputSource: '#prodigal2fasta/protein_fasta'
- id: rapsearch2_m8_files
  type:
    type: array
    items: File
  outputSource: '#rapsearch2/output_base'
- id: hmmscan_raw_files
  type:
    type: array
    items: File
  outputSource: '#hmmscan/output_base'
- id: hmmscan_htab_files
  type:
    type: array
    items: File
  outputSource: '#raw2htab/htab_file'
- id: tmhmm_raw_files
  type:
    type: array
    items: File
  outputSource: '#tmhmm/tmhmm_out'
- id: attributor_files
  type:
    type: array
    items: File
  outputSource: '#attributor/output_files'
- id: attributor_output_config
  type: File
  outputSource: '#attributor/the_config'
steps:
- id: barrnap
  run: {{cwl_tools_dir}}/barrnap.cwl
  in:
  - {id: barrnap.genomic_fasta, source: '#barrnap_genomic_fasta'}
  out:
  - {id: barrnap_gff_output}
- id: aragorn
  run: {{cwl_tools_dir}}/aragorn.cwl
  in:
  - {id: aragorn.genomic_fasta, source: '#source_fasta'}
  - {id: aragorn.aragorn_format, source: '#aragorn_format'}
  out:
  - {id: aragorn_raw_output}
- id: prodigal
  run: {{cwl_tools_dir}}/prodigal.cwl
  in:
  - {id: prodigal.genomic_fasta, source: '#source_fasta'}
  - {id: prodigal.output_format, source: '#output_format'}
  - {id: prodigal.annotation_out, source: '#initial_structural_prediction'}
  - {id: prodigal.protein_out, source: '#initial_protein_out'}
  out:
  - {id: prodigal_annot_file}
  - {id: prodigal_protein_file}
- id: prodigal2gff3
  run: {{cwl_tools_dir}}/biocode-ConvertProdigalToGFF3.cwl
  in:
  - {id: prodigal2gff3.input_file, source: '#prodigal/prodigal_annot_file'}
  - {id: prodigal2gff3.output_file, source: '#prodigal2gff3_output_file'}
  out:
  - {id: output_gff3}
- id: prodigal2fasta
  run: {{cwl_tools_dir}}/biocode-WriteFastaFromGFF.cwl
  in:
  - {id: prodigal2fasta.input_file, source: '#prodigal2gff3/output_gff3'}
  - {id: prodigal2fasta.output_file, source: '#prodigal2fasta_output_file'}
  - {id: prodigal2fasta.type, source: '#prodigal2fasta_type'}
  - {id: prodigal2fasta.fasta, source: '#source_fasta'}
  - {id: prodigal2fasta.feature_type, source: '#prodigal2fasta_feature_type'}
  out:
  - {id: protein_fasta}
- id: split_multifasta
  run: {{cwl_tools_dir}}/biocode-SplitFastaIntoEvenFiles.cwl
  in:
  - {id: split_multifasta.file_to_split, source: '#prodigal2fasta/protein_fasta'}
  - {id: split_multifasta.file_count, source: '#fragmentation_count'}
  - {id: split_multifasta.output_directory, source: '#out_dir'}
  out:
  - {id: fasta_files}
- id: rapsearch2
  run: {{cwl_tools_dir}}/rapsearch2.cwl
  in:
  - {id: rapsearch2.database_file, source: '#rapsearch2_database_file'}
  - {id: rapsearch2.query_file, source: '#split_multifasta/fasta_files'}
  - {id: rapsearch2.output_file_base, source: '#rapsearch2_output_file_base'}
  - {id: rapsearch2.thread_count, source: '#rapsearch2_threads'}
  - {id: rapsearch2.one_line_desc_count, source: '#rapsearch2_one_line_desc_count'}
  scatter: '#rapsearch2/rapsearch2.query_file'
  out:
  - {id: output_base}
- id: hmmscan
  run: {{cwl_tools_dir}}/hmmer3-hmmscan.cwl
  in:
  - {id: hmmscan.cutoff_gathering, source: '#hmmscan_cutoff_gathering'}
  - {id: hmmscan.use_accessions, source: '#hmmscan_use_accessions'}
  - {id: hmmscan.database_file, source: '#hmmscan_database_file'}
  - {id: hmmscan.query_file, source: '#split_multifasta/fasta_files'}
  - {id: hmmscan.output_file, source: '#hmmscan_output_file'}
  - {id: hmmscan.thread_count, source: '#hmmscan_threads'}
  scatter: '#hmmscan/hmmscan.query_file'
  out:
  - {id: output_base}
- id: raw2htab
  run: {{cwl_tools_dir}}/biocode-ConvertHmmscanToHtab.cwl
  in:
  - {id: raw2htab.input_file, source: '#hmmscan/output_base'}
  - {id: raw2htab.output_htab, source: '#raw2htab_output_htab'}
  - {id: raw2htab.mldbm_file, source: '#raw2htab_mldbm_file'}
  scatter: '#raw2htab/raw2htab.input_file'
  out:
  - {id: htab_file}
- id: tmhmm
  run: {{cwl_tools_dir}}/tmhmm.cwl
  in:
  - {id: tmhmm.query_file, source: '#split_multifasta/fasta_files'}
  scatter: '#tmhmm/tmhmm.query_file'
  out:
  - {id: tmhmm_out}
- id: attributor
  run: {{cwl_tools_dir}}/attributor-prok-cheetah.cwl
  in:
  - {id: attributor.config_file, source: '#attributor_config_file'}
  - {id: attributor.output_base, source: '#attributor_output_base'}
  - {id: attributor.output_format, source: '#attributor_output_format'}
  - {id: attributor.hmm_attribute_lookup_file, source: '#attributor_hmm_attribute_lookup_file'}
  - {id: attributor.blast_attribute_lookup_file, source: '#attributor_blast_attribute_lookup_file'}
  - {id: attributor.hmm_files, source: '#raw2htab/htab_file'}
  - {id: attributor.polypeptide_fasta, source: '#prodigal2fasta/protein_fasta'}
  - {id: attributor.source_gff3, source: '#prodigal2gff3/output_gff3'}
  - {id: attributor.m8_files, source: '#rapsearch2/output_base'}
  - {id: attributor.tmhmm_files, source: '#tmhmm/tmhmm_out'}
  out:
  - {id: output_files}
  - {id: the_config}

