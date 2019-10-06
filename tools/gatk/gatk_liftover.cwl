class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
baseCommand:
  - gatk
  - LiftoverVcf
arguments:  
#  - position: 0
#    prefix: '--java-options'
#    valueFrom: '-Xmx4G'
  - position: 4
    prefix: '--REJECT'
    valueFrom: $(inputs.vcf.nameroot + '.rejected.vcf')
  - position: 5
    prefix: '--OUTPUT'
    valueFrom: $(inputs.vcf.nameroot + '.lifted.vcf')
  - position: 6
    prefix: '--MAX_RECORDS_IN_RAM'
    valueFrom: '400000'
inputs:
  - id: reference
    type: 'File'
    inputBinding:
      position: 1
      prefix: '--REFERENCE_SEQUENCE'
    secondaryFiles: $(inputs.reference.nameroot + '.dict')
    doc: reference.fasta
  - id: vcf
    type: 'File'
    inputBinding:
      position: 2
      prefix: '--INPUT'
    doc: Input VCF file
  - id: chain
    type: 'File'
    inputBinding:
      position: 3
      prefix: '--CHAIN'
    doc: Chain  
outputs:
  - id: lifted
    type: File
    outputBinding:
      glob: '*.lifted.vcf'
  - id: rejected
    type: File
    outputBinding:
      glob: '*.rejected.vcf'
  - id: stdout
    type: stdout
  - id: stderr
    type: stderr
    
label: Tool for "lifting over" a VCF from one genome build to another, producing a properly headered, sorted and indexed VCF in one go.
hints:
  - class: DockerRequirement
    dockerPull: 'broadinstitute/gatk:latest'
stdout: gatk.liftover.stdout
stderr: gatk.liftover.stderr
requirements:
  - class: InlineJavascriptRequirement

