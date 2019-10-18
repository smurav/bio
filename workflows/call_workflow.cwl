#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

inputs:
  nthreads:
    type: int
  reference:
    type: File
    secondaryFiles: 
      - .fai
      - $(inputs.reference.nameroot + '.dict')
  bam:
    type: File
    secondaryFiles: 
      - $(inputs.bam.nameroot + '.bai')
  dbsnp:
    type: File
    secondaryFiles: '.tbi'
  clinvarVcf:
    type: File
outputs:
  gatk_call_vcf:
    type: File
    outputSource: call/vcf
  gatk_call_stdout:
    type: File
    outputSource: call/stdout
  gatk_call_stderr:
    type: File
    outputSource: call/stderr
  clinvar_all:
    type: File
    outputSource: clinvar/all
  clinvar_pathogenic:
    type: File
    outputSource: clinvar/pathogenic
  clinvar_likely_pathogenic:
    type: File
    outputSource: clinvar/likely_pathogenic
  clinvar_risk_factors:
    type: File
    outputSource: clinvar/risk_factors
  clinvar_stderr:
    type: File
    outputSource: clinvar/stderr
  clinvar_stdout:
    type: File
    outputSource: clinvar/stdout
steps:
  call:
    run: ../tools/gatk/gatk_call.cwl
    in:
      bam: bam
      reference: reference
      dbsnp: dbsnp
    out: ['vcf', 'stdout', 'stderr']
  clinvar:
    run: ../tools/smurav/smurav_clinvar.cwl
    in:
      inputVcf: call/vcf
      clinvarVcf: clinvarVcf
    out: ['all', 'pathogenic', 'likely_pathogenic', 'risk_factors', 'stdout', 'stderr']    
requirements:
  - class: InlineJavascriptRequirement
hints:
  ResourceRequirement:
    coresMin: 6
    coresMax: 6
    ramMin: 10000
    ramMax: 14000 
