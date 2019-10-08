#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

inputs:
  vcf:
    type: File
  bam:
    type: File
    secondaryFiles: 
      - $(inputs.bam.nameroot + '.bai')
  nthreads:
    type: int
  reference:
    type: File
    secondaryFiles: 
      - .fai
      - $(inputs.reference.nameroot + '.dict')
  filter_expression:
    type: string
  dbsnp:
    type: File?
    secondaryFiles: .tbi
  clinvar:
    type: File
    secondaryFiles: .tbi
  select:
    type: string
outputs:
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
    outputSource: annotate/outputFile
  annotate_stdout:
    type: File
    outputSource: annotate/stdout
  annotate_stderr:
    type: File
    outputSource: annotate/stderr   
  gatk_select_output:
    type: File
    outputSource: select/outputVcfFile
  gatk_select_stdout:
    type: File
    outputSource: select/stdout
  gatk_select_stderr:
    type: File
    outputSource: select/stderr
  gatk_table_output:
    type: File
    outputSource: table/tableFile
  gatk_table_stdout:
    type: File
    outputSource: table/stdout
  gatk_table_stderr:
    type: File
    outputSource: table/stderr
steps:
 
  filter:
    run: ../tools/bcftools/bcftools_view.cwl
    in:
      inputFile: vcf
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
  annotate:
    run: ../tools/gatk/gatk_annotate.cwl
    in:
      inputBamFile: bam
      inputVcfFile: vcf_tbi/vcf_with_index
      reference: reference
      dbsnp: dbsnp
      clinvar: clinvar
    out: ['outputFile', 'stdout', 'stderr']   
  select:
    run: ../tools/gatk/gatk_select.cwl
    in:
      reference: reference
      inputVcfFile: annotate/outputFile
      select: select
    out: ['outputVcfFile', 'stdout', 'stderr']    
  table:
    run: ../tools/gatk/gatk_table.cwl
    in:
      reference: reference
      inputVcfFile: select/outputVcfFile
    out: ['tableFile', 'stdout', 'stderr']   
requirements:
  - class: InlineJavascriptRequirement
hints:
  ResourceRequirement:
    coresMin: 6
    coresMax: 6
    ramMin: 10000
    ramMax: 14000 
