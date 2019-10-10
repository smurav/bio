class: CommandLineTool
cwlVersion: v1.0
baseCommand:
  - gatk
  - ValidateSamFile
inputs:
  - id: inputFile
    type: 'File'
    inputBinding:
      position: 2
      prefix: '-I'
  - id: reference
    type: 'File'
    inputBinding:
      position: 3
      prefix: '-R'
    doc: reference.fasta 

outputs:
  - id: outputFile
    type: File
    outputBinding:
      glob: '*.summary'
  - id: stdout
    type: stdout
  - id: stderr
    type: stderr
    
arguments:
  - position: 4
    prefix: '-O'
    valueFrom: $(inputs.inputFile.basename + '.summary')
  - position: 5
    prefix: '-M'
    valueFrom: 'SUMMARY'
    
hints:
  - class: DockerRequirement
    dockerPull: 'broadinstitute/gatk:latest'
stdout: gatk.validate.stdout
stderr: gatk.validate.stderr
requirements:
  - class: InlineJavascriptRequirement
