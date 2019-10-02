class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
baseCommand:
  - gatk
inputs:
  - id: inputFile
    type: 'File'
    inputBinding:
      position: 5
      prefix: '--INPUT='
    doc: One or more input SAM or BAM files to analyze. Must be coordinate sorted.
outputs:
  - id: markdup_output
    type: File
    outputBinding:
      glob: $(inputs.inputFile.nameroot + '.markdup.bam')
  - id: markdup_metrics
    type: File
    outputBinding:
      glob: $("*.metrics")
  - id: markdup_index
    type: File
    outputBinding:
      glob: $("*.bai")
  - id: stdout
    type: stdout
  - id: stderr
    type: stderr
doc: >-
  https://software.broadinstitute.org/gatk/documentation/tooldocs/4.0.4.0/picard_sam_markduplicates_MarkDuplicates.php
label: This tool locates and tags duplicate reads in a BAM or SAM file
arguments:
  - position: 1
    valueFrom: MarkDuplicates
  - position: 2
    valueFrom: '--VALIDATION_STRINGENCY=SILENT'
  - position: 3
    valueFrom: '--REMOVE_DUPLICATES'
  - position: 4
    valueFrom: '--CREATE_INDEX'
  - position: 6
    prefix: '--METRICS_FILE='
    separate: false
    valueFrom: $(inputs.inputFile.nameroot + '.markdup.metrics')
  - position: 7
    prefix: '--OUTPUT='
    separate: false
    valueFrom: $(inputs.inputFile.nameroot + '.markdup.bam')
hints:
  - class: DockerRequirement
    dockerPull: 'broadinstitute/gatk:latest'
stdout: gatk.markdup.stdout
stderr: gatk.markdup.stderr
requirements:
  - class: InlineJavascriptRequirement
