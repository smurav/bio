#!/usr/bin/env cwl-runner
# Подготовка необходимых исходных данных

cwlVersion: v1.0
class: Workflow

inputs:
  reference:
    type: File
  index_basename:
    type: string
outputs:
  faidx:
    type: File[]
    outputSource: build_fai/result
  dict:
    type: File
    outputSource: build_dict/dictFile
  h2_index:
    type: File[]
    outputSource: index/index_files
steps:
  build_fai:
    run: ../tools/samtools/samtools_faidx.cwl
    in:
      reference: reference
    out: ['result']  
  build_dict:
    run: ../tools/gatk/gatk_dict.cwl
    in:
      reference: reference
    out: ['dictFile']
  index:
    run: ../tools/hisat2/hisat2_index.cwl
    in:
      reference_fasta: reference
      index_basename: index_basename
    out: ['index_files']
