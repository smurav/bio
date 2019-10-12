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
  mpileup:
    run: ../tools/bcftools/bcftools_mpileup.cwl
    in:
      inputFile: markdup/markdup_output
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
      inputBamFile: bam_bai/bam_with_index
      inputVcfFile: vcf_tbi/vcf_with_index
      reference: reference
      dbsnp: dbsnp
      clinvar: clinvar
    out: ['outputFile', 'stdout', 'stderr']   
  SelectVariants:
    run: ../tools/gatk/gatk_select.cwl
    in:
      reference: reference
      inputVcfFile: VariantAnnotator/outputFile
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
