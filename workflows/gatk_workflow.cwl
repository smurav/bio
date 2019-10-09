#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

inputs:
  sample:
    type: string
  data_dir:
    type: Directory
  adapter1:
    type: string
  adapter2:
    type: string
  fastp_custom_args:
    type: string?
  hisat2_idx_basedir: 
    type: Directory
  hisat2_idx_basename:
    type: string
  nthreads:
    type: int
  reference:
    type: File
    secondaryFiles: 
      - .fai
      - $(inputs.reference.nameroot + '.dict')
  rg_id:
    type: string
  rg:
    type: string
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
  #fastp_out1_cleaned_fq:
    #type: File
    #outputSource: clean/out1_cleaned_fq
  #fastp_out2_cleaned_fq:
    #type: File
    #outputSource: clean/out2_cleaned_fq
  #fastp_out1_unpaired_fq:
    #type: File
    #outputSource: clean/out2_unpaired_fq  
  #fastp_out2_unpaired_fq:
    #type: File
    #outputSource: clean/out2_unpaired_fq  
  fastp_report_json:
    type: File
    outputSource: clean/report_json
  fastp_report_html:
    type: File
    outputSource: clean/report_html
  fastp_stdout:
    type: File
    outputSource: clean/stdout
  fastp_stderr:
    type: File
    outputSource: clean/stderr
# Не сохраняем для экономии места
#  hisat2_sam:
#    type: File
#    outputSource: map/hisat2_sam
  hisat2_stdout:
    type: File
    outputSource: map/stdout
  hisat2_stderr:
    type: File
    outputSource: map/stderr
  #samtools_fixmate_bam:
    #type: File
    #outputSource: fixmate/bam
  samtools_fixmate_stdout:
    type: File
    outputSource: fixmate/stdout
  samtools_fixmate_stderr:
    type: File
    outputSource: fixmate/stderr
#  samtools_sort_bam:
#    type: File
#    outputSource: sort/bam_sorted
  samtools_sort_stdout:
    type: File
    outputSource: sort/stdout
  samtools_sort_stderr:
    type: File
    outputSource: sort/stderr
  
# Результаты удаления дубликатов и индекс
  gatk_markdup_output:
    type: File
    outputSource: markdup/markdup_output
  gatk_markdup_metrics:
    type: File
    outputSource: markdup/markdup_metrics
  gatk_markdup_index:
    type: File
    outputSource: markdup/markdup_index
  gatk_markdup_stdout:
    type: File
    outputSource: markdup/stdout
  gatk_markdup_stderr:
    type: File
    outputSource: markdup/stderr
  gatk_call_vcf:
    type: File
    outputSource: call/vcf
  gatk_call_stdout:
    type: File
    outputSource: call/stdout
  gatk_call_stderr:
    type: File
    outputSource: call/stderr
steps:
  clean:
    run: ../tools/fastp/fastp_pe.cwl
    in:
      nthreads: nthreads
      sample: sample
      data_dir: data_dir
      adapter1: adapter1
      adapter2: adapter2
      custom_args: fastp_custom_args
    out: ['out1_cleaned_fq', 'out1_unpaired_fq', 'out2_cleaned_fq', 
    'out2_unpaired_fq', 'report_json', 'report_html', 'stdout', 
    'stderr']

  map:
    run: ../tools/hisat2/hisat2_mapping_pe.cwl
    in:
      hisat2_idx_basedir: hisat2_idx_basedir
      hisat2_idx_basename: hisat2_idx_basename
      fq1: clean/out1_cleaned_fq
      fq2: clean/out2_cleaned_fq
      sample: sample
      nthreads: nthreads
      rg_id: rg_id
      rg: rg
    out: ['hisat2_sam', 'stdout', 'stderr']

  fixmate:
    run: ../tools/samtools/samtools_fixmate.cwl
    in:
      sam: map/hisat2_sam
    out: ['bam', 'stdout', 'stderr']

# Сортировка
  sort:
    run: ../tools/samtools/samtools_sort.cwl
    in:
      bam_unsorted: fixmate/bam
    out: ['bam_sorted', 'stdout', 'stderr']

# Удаление дубликатов
  markdup:
    run: ../tools/gatk/gatk_markdup.cwl
    in:
      inputFile: sort/bam_sorted
    out: ['markdup_output', 'markdup_metrics', 'markdup_index', 'stdout', 'stderr']
    
  bam_bai:
    run: ../tools/gatk/gatk_bam_bai.cwl
    in:
      bam: markdup/markdup_output
      bai: markdup/markdup_index
    out: ['bam_with_index']

# Поиск вариантов
  call:
    run: ../tools/gatk/gatk_call.cwl
    in:
      bam: markdup/markdup_output
      reference: reference
    out: ['vcf', 'sdtout', 'stderr']
requirements:
  - class: InlineJavascriptRequirement
hints:
  ResourceRequirement:
    coresMin: 6
    coresMax: 6
    ramMin: 10000
    ramMax: 14000 
