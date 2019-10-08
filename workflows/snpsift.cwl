#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

inputs:
  inputVcfFile:
    type: File
  reference:
    type: File
    secondaryFiles: 
      - .fai
      - $(inputs.reference.nameroot + '.dict')
  dbsnp:
    type: File?
    secondaryFiles: .tbi
  clinvar:
    type: File
    secondaryFiles: .tbi
  select:
    type: string
outputs:
  annotate_output:
    type: File
    outputSource: snpsift/outputVcfFile
  annotate_stderr:
    type: File
    outputSource: snpsift/stderr   
  gatk_select_output:
    type: File
    outputSource: SelectVariants/outputVcfFile
  gatk_select_stdout:
    type: File
    outputSource: SelectVariants/stdout
  gatk_select_stderr:
    type: File
    outputSource: SelectVariants/stderr
  gatk_table_output:
    type: File
    outputSource: VariantsToTable/tableFile
  gatk_table_stdout:
    type: File
    outputSource: VariantsToTable/stdout
  gatk_table_stderr:
    type: File
    outputSource: VariantsToTable/stderr
steps:
  snpsift:
    run: ../tools/snpsift/snpsift_annotate.cwl
    in:
      inputVcfFile: inputVcfFile
      database: clinvar
    out: ['outputVcfFile', 'stderr']   
  SelectVariants:
    run: ../tools/gatk/gatk_select.cwl
    in:
      reference: reference
      inputVcfFile: snpsift/outputVcfFile
      select: select
    out: ['outputVcfFile', 'stdout', 'stderr']    
  VariantsToTable:
    run: ../tools/gatk/gatk_table.cwl
    in:
      reference: reference
      inputVcfFile: SelectVariants/outputVcfFile
    out: ['tableFile', 'stdout', 'stderr']   
requirements:
  - class: InlineJavascriptRequirement
hints:
  ResourceRequirement:
    coresMin: 6
    coresMax: 6
    ramMin: 10000
    ramMax: 14000 
