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
  - id: all
    type: File
    outputBinding:
      glob: '*.all.csv'
  - id: pathogenic
    type: File
    outputBinding:
      glob: '*.pathogenic.csv'
  - id: likely_pathogenic
    type: File
    outputBinding:
      glob: '*.likely_pathogenic.csv'
  - id: risk_factors
    type: File
    outputBinding:
      glob: '*.risk_factors.csv'
  - id: stdout
    type: stdout
  - id: stderr
    type: stderr
hints:
  DockerRequirement:
    dockerPull: 'smurav/clinvar'
stdout: smurav.clinvar.stdout
stderr: smurav.clinvar.stderr
