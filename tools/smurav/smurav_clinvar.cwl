class: CommandLineTool
cwlVersion: v1.0
id: clinvar
inputs:
  - id: inputVcf
    type: File
    inputBinding:
      position: 1
    label: vcf-файл с аннотациями dbSNP
  - id: clinvarVcf
    type: File
    inputBinding:
      position: 2
    label: clinvar.vcf
outputs:
  - id: pathogenic
    type: File
    outputBinding:
      glob: '*.csv'
  - id: stdout
    type: stdout
  - id: stderr
    type: stderr
hints:
  DockerRequirement:
    dockerPull: 'smurav/clinvar'
stdout: clinvar.stdout

