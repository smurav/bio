#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

inputs:
  in1:
    type: File
  in2:
    type: File
  adapter1:
    type: string?
  adapter2:
    type: string?
  fastp_custom_args:
    type: string?
  hisat2_idx_basedir: 
    type: Directory
  hisat2_idx_basename:
    type: string
  hisat2_out_sam_name:
    type: string?
  nthreads:
    type: int

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
  samtools_sort_bam:
    type: File
    outputSource: sort/bam_sorted
  samtools_sort_stdout:
    type: File
    outputSource: sort/stdout
  samtools_sort_stderr:
    type: File
    outputSource: sort/stderr
    
steps:
  clean:
    run: ../tools/fastp/fastp_pe.cwl
    in:
      nthreads: nthreads
      in1: in1
      in2: in2
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
      out_sam_name: hisat2_out_sam_name
      nthreads: nthreads
    out: ['hisat2_sam', 'stdout', 'stderr']

  fixmate:
    run: ../tools/samtools/samtools_fixmate.cwl
    in:
      sam: map/hisat2_sam
    out: ['bam', 'stdout', 'stderr']
    
  sort:
    run: ../tools/samtools/samtools_sort.cwl
    in:
      bam_unsorted: fixmate/bam
    out: ['bam_sorted', 'stdout', 'stderr']
