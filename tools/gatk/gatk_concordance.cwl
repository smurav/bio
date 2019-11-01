class: CommandLineTool
cwlVersion: v1.0
baseCommand:
  - gatk
  - Concordance
inputs:
  - id: reference
    type: File
    inputBinding:
      position: 3
      prefix: '-R'
    secondaryFiles: 
      - .fai
      - $(inputs.reference.nameroot + '.dict')
  - id: eval
    type: File
    inputBinding:
      position: 4
      prefix: '-eval'
    doc: The variants and genotypes to evaluate
  - id: truth
    type: File
    inputBinding:
      position: 5
      prefix: '--truth'
    doc: The variants and genotypes to compare against
  - id: intervals
    type: File
    inputBinding:
      position: 6
      prefix: '-L'
outputs:
  - id: summary
    type: File
    outputBinding:
      glob: '*.tsv'
  - id: stdout
    type: stdout
  - id: stderr
    type: stderr
arguments:
  - position: 7
    prefix: '--summary'
    valueFrom: $(inputs.eval.nameroot + '.summary.tsv')
hints:
  - class: DockerRequirement
    dockerPull: 'broadinstitute/gatk:latest'
stdout: gatk.concordance.stdout
stderr: gatk.concordance.stderr
requirements:
  - class: InlineJavascriptRequirement
