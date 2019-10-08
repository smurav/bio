class: CommandLineTool
cwlVersion: v1.0
baseCommand:
  - Annotate
inputs:
  - id: database
    type: File
    inputBinding:
      position: 2
  - id: inputVcfFile
    type: File
    inputBinding:
      position: 3
outputs:
  - id: outputVcfFile
    type: stdout
  - id: stderr
    type: stderr
requirements:
  - class: DockerRequirement
    dockerPull: alexcoppe/snpsift
  - class: InlineJavascriptRequirement
stdout: $(inputs.inputVcfFile.nameroot + '.snpsift.vcf')
stderr: snpsift.annotate.stderr
