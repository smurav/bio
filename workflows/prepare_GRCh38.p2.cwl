#!/usr/bin/env cwl-runner
# Подготовка необходимых исходных данных

cwlVersion: v1.0
class: Workflow

inputs:
  packed_reference:
    type: File
  index_basename:
    type: string
outputs:
  reference:
    type: File
    outputSource: extract_ref/output
  dict:
    type: File
    outputSource: build_dict/dictFile
  h2_index:
    type: File[]
    outputSource: h2_index/index_files
steps:
  extract_ref:
    run: ../tools/arc/gunzip.cwl
    in:
      archive: packed_reference
    out: ['output']
  build_dict:
    run: ../tools/gatk/gatk_dict.cwl
    in:
      reference: extract_ref/output
    out: ['dictFile']
  h2_index:
    run: ../tools/hisat2/hisat2_index.cwl
    in:
      reference_fasta: extract_ref/output
      index_basename: index_basename
    out: ['index_files']

