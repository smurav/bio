class: CommandLineTool
cwlVersion: v1.0
id: gunzip
baseCommand:
  - 'gunzip'
  - '-c'

inputs:
  archive:
    type: File
    inputBinding:
      position: 1

outputs:
    output:
        type: stdout

stdout: $(inputs.archive.nameroot)

requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
