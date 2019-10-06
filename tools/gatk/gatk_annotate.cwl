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
    type: File?
    inputBinding:
      position: 5
      prefix: '-D'
    doc: dbSNP file  
    secondaryFiles: .tbi
  - id: clinvar
    type: File
    inputBinding:
      position: 7
      prefix: '--resource:clinvar'
    secondaryFiles: .tbi
arguments:
  - position: 4
    prefix: '-O'
    valueFrom: $(inputs.inputVcfFile.nameroot + '.annotated.vcf')
  - position: 6
    prefix: '-A'
    valueFrom: Coverage
  - position: 8
    prefix: '-E'
    valueFrom: clinvar.ID
  - position: 8
    prefix: '-E'
    valueFrom: clinvar.CLNSIG
  - position: 8
    prefix: '-E'
    valueFrom: clinvar.CLNSIGCONF
  - position: 8
    prefix: '-E'
    valueFrom: clinvar.CLNSIGINCL
  - position: 8
    prefix: '-E'
    valueFrom: clinvar.CLNACC
  - position: 8
    prefix: '-E'
    valueFrom: clinvar.ALLELEID
  - position: 8
    prefix: '-E'
    valueFrom: clinvar.CLNDN
  - position: 8
    prefix: '-E'
    valueFrom: clinvar.CLNDNINCL
  - position: 8
    prefix: '-E'
    valueFrom: clinvar.CLNDISDB
  - position: 8
    prefix: '-E'
    valueFrom: clinvar.CLNDISDBINCL
  - position: 8
    prefix: '-E'
    valueFrom: clinvar.CLNVC
  - position: 8
    prefix: '-E'
    valueFrom: clinvar.CLNVCSO
  - position: 8
    prefix: '-E'
    valueFrom: clinvar.CLNVI
  - position: 8
    prefix: '-E'
    valueFrom: clinvar.DBVARID
  - position: 8
    prefix: '-E'
    valueFrom: clinvar.GENEINFO
  - position: 8
    prefix: '-E'
    valueFrom: clinvar.MC
  - position: 8
    prefix: '-E'
    valueFrom: clinvar.ORIGIN
  - position: 8
    prefix: '-E'
    valueFrom: clinvar.RS
  - position: 8
    prefix: '-E'
    valueFrom: clinvar.SSR
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

hints:
  - class: DockerRequirement
    dockerPull: 'broadinstitute/gatk:latest'
stdout: gatk.annotate.stdout
stderr: gatk.annotate.stderr
requirements:
  - class: InlineJavascriptRequirement
