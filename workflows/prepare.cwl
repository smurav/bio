#!/usr/bin/env cwl-runner
# Подготовка необходимых исходных данных

cwlVersion: v1.0
class: Workflow

inputs:
  reference:
    type: File
outputs:
  dict_file:
    type: File
    outputSource: dict/dictFile
  dictt_stdout:
    type: File
    outputSource: dict/stdout
  dict_stderr:
    type: File
    outputSource: dict/stderr
steps:
  dict:
    run: ../tools/gatk/gatk_dict.cwl
    in:
      reference: reference
    out: ['dictFile', 'stdout', 'stderr']
