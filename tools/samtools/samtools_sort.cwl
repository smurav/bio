#!/usr/bin/env cwl-runner
doc: Sort a bam file by read names.
cwlVersion: v1.0
class: CommandLineTool

requirements:
  InlineJavascriptRequirement: {}
hints:
  ResourceRequirement:
    coresMin: 4
    ramMin: 15000
  DockerRequirement:
    dockerPull: quay.io/biocontainers/samtools:1.9--h46bd0b3_0
#    dockerPull: 'biocontainers/samtools:v1.7.0_cv4'

baseCommand: ["samtools", "sort"]
arguments:
  - valueFrom: $(runtime.cores)
    prefix: -@
  - prefix: -m
    valueFrom: ${ return(parseInt(runtime.ram/runtime.cores-100).toString() + "M") }
    position: 1
    # specifies the allowed maximal memory usage per thread before
    # samtools start to outsource memory to temporary files
  - valueFrom: $(inputs.bam_unsorted.nameroot + '.sorted.bam')
    prefix: -o

inputs:
  bam_unsorted:
    doc: aligned reads to be checked in sam or bam format
    type: File
    inputBinding:
      position: 2
  by_name:
    doc: If true, will sort by name, otherwise will sort by genomic position
    type: boolean
    default: false
    inputBinding:
      position: 1
      prefix: -n

outputs:
  - id: bam_sorted
    type: File
    outputBinding:
      glob: $(inputs.bam_unsorted.nameroot + '.sorted.bam')
  - id: stdout
    type: stdout
  - id: stderr
    type: stderr
      
stdout: samtools.sort.stdout
stderr: samtools.sort.stderr  
