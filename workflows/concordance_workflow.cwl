#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

inputs:
  reference:
    type: File
    secondaryFiles: 
      - .fai
      - $(inputs.reference.nameroot + '.dict')
  eval:
    type: File
    secondaryFiles: '.tbi'
  truth:
    type: File
    secondaryFiles: '.tbi'
outputs:
  concordance_summary:
    type: File
    outputSource: concordance/summary
  concordance_stderr:
    type: File
    outputSource: concordance/stderr
  concordance_stdout:
    type: File
    outputSource: concordance/stdout
steps:
  concordance:
    run: ../tools/gatk/gatk_concordance.cwl
    in:
      reference: reference
      truth: truth
      eval: eval
    out: ['summary', 'stdout', 'stderr']
requirements:
  - class: InlineJavascriptRequirement
hints:
  ResourceRequirement:
    coresMin: 6
    coresMax: 6
    ramMin: 10000
    ramMax: 14000 
