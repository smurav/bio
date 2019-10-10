#!/usr/bin/env cwl-runner
# Подготовка необходимых исходных данных

cwlVersion: v1.0
class: Workflow

inputs:
  packed_reference:
    type: File
  packed_h2_index:
    type: File
outputs:
  reference:
    type: File
    outputSource: extract_ref/output
  dict:
    type: File
    outputSource: build_dict/dictFile
  h2_index:
    type: File[]
    outputSource: extract_h2_index/output
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
  extract_h2_index:
    run: ../tools/arc/untar.cwl
    in:
      archive: packed_h2_index
    out: ['output']

