class: CommandLineTool
cwlVersion: v1.0
baseCommand:
  - gatk
  - HaplotypeCaller
inputs:
  - id: reference
    type: File?
    inputBinding:
      position: 3
      prefix: '-R'
    secondaryFiles: 
      - .fai
      - $(inputs.reference.nameroot + '.dict')
  - id: bam
    type: File
    inputBinding:
      position: 4
      prefix: '-I'
    secondaryFiles: .bai
  #- id: dbsnp
    #type: File
    #inputBinding:
      #position: 5
      #prefix: '--dbsnp'
    #secondaryFiles: .tbi
  #- id: clinvar
    #type: File
    #inputBinding:
      #position: 6
      #prefix: '--comp'
    #secondaryFiles: .tbi
outputs:
  - id: vcf
    type: File
    outputBinding:
      glob: '*.vcf'
  - id: stdout
    type: stdout
  - id: stderr
    type: stderr
arguments:
  - position: 7
    prefix: '-O'
    valueFrom: $(inputs.bam.nameroot + '.vcf')
hints:
  - class: DockerRequirement
    dockerPull: 'broadinstitute/gatk:latest'
stdout: gatk.call.stdout
stderr: gatk.call.stderr
requirements:
  - class: InlineJavascriptRequirement
