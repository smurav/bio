class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
baseCommand:
  - bcftools
  - mpileup
  - '-Ou'
inputs:
  - id: inputFile
    type: File
    inputBinding:
      position: 4
  - id: reference
    type: File
    inputBinding:
      position: 3
      prefix: '-f'
    secondaryFiles: .fai
outputs:
  - id: outputFile
    type: stdout
  - id: stderr
    type: stderr
hints:
  - class: DockerRequirement
    dockerPull: 'biocontainers/bcftools:v1.9-1-deb_cv1'
stdout: $(inputs.inputFile.nameroot + '.vcf')
stderr: bcftools.mpileup.stderr
requirements:
  - class: InlineJavascriptRequirement
