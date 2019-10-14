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
  filter_expression:
    type: string
  dbsnp:
    type: File
    secondaryFiles: '.tbi'
  clinvarVcf:
    type: File
outputs:
# Поиск вариантов
#  bcftools_mpileup_output:
#    type: File
#    outputSource: mpileup/outputFile
  bcftools_mpileup_stderr:
    type: File
    outputSource: mpileup/stderr
#  bcftools_call_output:
#    type: File
#    outputSource: call/outputFile
  bcftools_call_stderr:
    type: File
    outputSource: call/stderr
  filter_output:
    type: File
    outputSource: filter/outputFile
  filter_stdout:
    type: File
    outputSource: filter/stdout
  filter_stderr:
    type: File
    outputSource: filter/stderr     
  tbi_output:
    type: File
    outputSource: tbi/outputFile
  tbi_stdout:
    type: File
    outputSource: tbi/stdout
  tbi_stderr:
    type: File
    outputSource: tbi/stderr    
  annotate_output:
    type: File
    outputSource: VariantAnnotator/outputFile
  annotate_stdout:
    type: File
    outputSource: VariantAnnotator/stdout
  annotate_stderr:
    type: File
    outputSource: VariantAnnotator/stderr   
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
  mpileup:
    run: ../tools/bcftools/bcftools_mpileup.cwl
    in:
      inputFile: bam
      reference: reference
    out: ['outputFile', 'stderr']
  call:
    run: ../tools/bcftools/bcftools_call.cwl
    in:
      inputFile: mpileup/outputFile
      nthreads: nthreads
    out: ['outputFile', 'stderr']
  filter:
    run: ../tools/bcftools/bcftools_view.cwl
    in:
      inputFile: call/outputFile
      include_expression: filter_expression
      nthreads: nthreads
    out: ['outputFile', 'stdout', 'stderr']   
  tbi:
    run: ../tools/gatk/gatk_tbi.cwl
    in:
      inputFile: filter/outputFile
    out: ['outputFile', 'stdout', 'stderr']
  vcf_tbi:
    run: ../tools/gatk/gatk_vcf_tbi.cwl
    in:
      vcf: filter/outputFile
      tbi: tbi/outputFile
    out: ['vcf_with_index']
  VariantAnnotator:
    run: ../tools/gatk/gatk_annotate.cwl
    in:
      inputBamFile: bam
      inputVcfFile: vcf_tbi/vcf_with_index
      reference: reference
      dbsnp: dbsnp
    out: ['outputFile', 'stdout', 'stderr']
  clinvar:
    run: ../tools/smurav/smurav_clinvar.cwl
    in:
      inputVcf: VariantAnnotator/outputFile
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
