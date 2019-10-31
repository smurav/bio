class: CommandLineTool
cwlVersion: v1.0
baseCommand:
  - gatk
  - GenotypeConcordance
inputs:
  - id: eval
    type: File
    inputBinding:
      position: 4
      prefix: '--CALL_VCF'
    doc: The variants and genotypes to evaluate
  - id: comp
    type: File
    inputBinding:
      position: 5
      prefix: '--TRUTH_VCF'
    doc: The variants and genotypes to compare against  
outputs:
  - id: report
    type: File
    outputBinding:
      glob: '*.genotype_concordance_*'
  - id: stdout
    type: stdout
  - id: stderr
    type: stderr
arguments:
  - position: 7
    prefix: '--OUTPUT'
    valueFrom: $(inputs.eval.nameroot)
hints:
  - class: DockerRequirement
    dockerPull: 'broadinstitute/gatk:latest'
stdout: gatk.concordance.stdout
stderr: gatk.concordance.stderr
requirements:
  - class: InlineJavascriptRequirement
