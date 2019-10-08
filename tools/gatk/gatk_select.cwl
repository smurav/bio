class: CommandLineTool
cwlVersion: v1.0
baseCommand:
  - gatk
  - SelectVariants
inputs:
  - id: reference
    type: 'File'
    inputBinding:
      position: 2
      prefix: '-R'
    doc: reference.fasta 
  - id: inputVcfFile
    type: 'File'
    inputBinding:
      position: 3
      prefix: '-V'
    doc: Input VCF file
  - id: select
    type: string
    inputBinding:
      position: 4
      prefix: '-select'
arguments:
  - position: 4
    prefix: '-O'
    valueFrom: $(inputs.inputVcfFile.nameroot + '.selected.vcf')
outputs:
  - id: outputVcfFile
    type: File
    outputBinding:
      glob: '*.selected.vcf'
  - id: stdout
    type: stdout
  - id: stderr
    type: stderr
hints:
  - class: DockerRequirement
    dockerPull: 'broadinstitute/gatk:latest'
stdout: gatk.select.stdout
stderr: gatk.select.stderr
requirements:
  - class: InlineJavascriptRequirement

