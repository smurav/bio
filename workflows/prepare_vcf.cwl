#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

inputs:
  reference:
    type: File
    secondaryFiles: 
      - .fai
      - $(inputs.reference.nameroot + '.dict')
  vcf:
    type: File
  chain:
    type: File
outputs:
  liftover_vcf:
    type: File
    outputSource: liftover/lifted
  liftover_rejected:
    type: File
    outputSource: liftover/rejected
  liftover_stdout:
    type: File
    outputSource: liftover/stdout
  liftover_stderr:
    type: File
    outputSource: liftover/stderr
steps:
  liftover:
    run: ../tools/gatk/gatk_liftover.cwl
    in:
      reference: reference
      vcf: vcf
      chain: chain
    out: ['lifted', 'rejected', 'stdout', 'stderr']
requirements:
  - class: InlineJavascriptRequirement
