class: CommandLineTool
cwlVersion: v1.0
baseCommand:
  - gatk
  - IndexFeatureFile
inputs:
  - id: inputFile
    type: 'File'
    inputBinding:
      position: 2
      prefix: '-F'
    doc: Feature file (eg., VCF or BED file) to index.

outputs:
  - id: outputFile
    type: File
    outputBinding:
      glob: '*.tbi'
  - id: stdout
    type: stdout
  - id: stderr
    type: stderr
    
label: Creates an index for a feature file
arguments:
  - position: 3
    prefix: '-O'
    valueFrom: $(inputs.inputFile.basename + '.tbi')
    
hints:
  - class: DockerRequirement
    dockerPull: 'broadinstitute/gatk:latest'
stdout: gatk.tbi.stdout
stderr: gatk.tbi.stderr
requirements:
  - class: InlineJavascriptRequirement
