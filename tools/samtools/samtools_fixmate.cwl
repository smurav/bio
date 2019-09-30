class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
baseCommand:
  - samtools
  - fixmate
inputs:
  - id: sam
    type: File
    inputBinding:
      position: 2
outputs:
  - id: bam
    type: File
    outputBinding:
      glob: $(inputs.sam.nameroot + '.bam')
  - id: stdout
    type: stdout
  - id: stderr
    type: stderr
arguments:
  - position: 0
    prefix: '-r'
    separate: false
  - position: 1
    prefix: '-O'
    valueFrom: bam
  - position: 3
    valueFrom: $(inputs.sam.nameroot + '.bam')
requirements:
  - class: DockerRequirement
    dockerPull: 'biocontainers/samtools:v1.7.0_cv4'
  - class: InlineJavascriptRequirement
stdout: samtools.fixmate.stdout
stderr: samtools.fixmate.stderr
