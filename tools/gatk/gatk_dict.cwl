class: CommandLineTool
cwlVersion: v1.0
baseCommand:
  - gatk
  - CreateSequenceDictionary
inputs:
  - id: reference
    type: 'File'
    inputBinding:
      position: 2
      prefix: '-R'
    doc: reference.fasta 

outputs:
  - id: dictFile
    type: File
    outputBinding:
      glob: '*.dict'
  - id: stdout
    type: stdout
  - id: stderr
    type: stderr
    
label: Creates a sequence dictionary for a reference sequence. 
arguments:
  - position: 3
    prefix: '-O'
    valueFrom: $(inputs.reference.nameroot + '.dict')

    
hints:
  - class: DockerRequirement
    dockerPull: 'broadinstitute/gatk:latest'
stdout: gatk.dict.stdout
stderr: gatk.dict.stderr
requirements:
  - class: InlineJavascriptRequirement
