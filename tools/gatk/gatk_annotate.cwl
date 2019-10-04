class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
baseCommand:
  - gatk
  - VariantAnnotator
inputs:
  - id: inputBamFile
    type: File?
    inputBinding:
      position: 1
      prefix: '-I'
    doc: One or more input SAM or BAM files to analyze. Must be coordinate sorted.
    secondaryFiles: $(inputs.inputBamFile.nameroot + '.bai')
  - id: reference
    type: 'File'
    inputBinding:
      position: 2
      prefix: '-R'
    secondaryFiles: $(inputs.reference.nameroot + '.dict')
    doc: reference.fasta
  - id: inputVcfFile
    type: 'File'
    inputBinding:
      position: 3
      prefix: '-V'
    doc: Input VCF file
    secondaryFiles: .tbi
  - id: dbsnp
    type: 'File'
    inputBinding:
      position: 5
      prefix: '-D'
    doc: dbSNP file  
    secondaryFiles: .tbi
outputs:
  - id: outputFile
    type: File
    outputBinding:
      glob: '*.annotated.vcf'
  - id: stdout
    type: stdout
  - id: stderr
    type: stderr
    
label: This tool is designed to annotate variant calls based on their context 
arguments:
  - position: 4
    prefix: '-O'
    valueFrom: $(inputs.inputVcfFile.nameroot + '.annotated.vcf')
  - position: 6
    prefix: '-A'
    valueFrom: Coverage
hints:
  - class: DockerRequirement
    dockerPull: 'broadinstitute/gatk:latest'
stdout: gatk.annotate.stdout
stderr: gatk.annotate.stderr
requirements:
  - class: InlineJavascriptRequirement

