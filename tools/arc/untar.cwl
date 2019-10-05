class: CommandLineTool
cwlVersion: v1.0
id: untar
baseCommand:
  - 'tar'
  - '-xzf'
inputs:
  archive:
    type: File
    inputBinding:
      position: 2
outputs:
  output:
    type: File[]
    outputBinding:
      glob: "*.*"
requirements:
  - class: ShellCommandRequirement
