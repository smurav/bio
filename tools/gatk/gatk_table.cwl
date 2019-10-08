class: CommandLineTool
cwlVersion: v1.0
baseCommand:
  - gatk
  - VariantsToTable
inputs:
  - id: reference
    type: 'File'
    inputBinding:
      position: 2
      prefix: '-R'
    doc: reference.fasta 
  - id: inputVcfFile
    type: 'File'
    inputBinding:
      position: 3
      prefix: '-V'
    doc: Input VCF file
arguments:
  - position: 4
    prefix: '-O'
    valueFrom: $(inputs.inputVcfFile.nameroot + '.table')
  - position: 8
    prefix: '-F'
    valueFrom: CHROM
  - position: 8
    prefix: '-F'
    valueFrom: POS
  - position: 8
    prefix: '-F'
    valueFrom: ID
  - position: 8
    prefix: '-F'
    valueFrom: QUAL
  - position: 8
    prefix: '-F'
    valueFrom: AD
  - position: 8
    prefix: '-GF'
    valueFrom: PL
  - position: 8
    prefix: '-F'
    valueFrom: clinvar.ID
  - position: 8
    prefix: '-F'
    valueFrom: clinvar.CLNSIG
  - position: 8
    prefix: '-F'
    valueFrom: clinvar.CLNSIGCONF
  - position: 8
    prefix: '-F'
    valueFrom: clinvar.CLNSIGINCL
  - position: 8
    prefix: '-F'
    valueFrom: clinvar.CLNACC
  - position: 8
    prefix: '-F'
    valueFrom: clinvar.ALLELEID
  - position: 8
    prefix: '-F'
    valueFrom: clinvar.CLNDN
  - position: 8
    prefix: '-F'
    valueFrom: clinvar.CLNDNINCL
  - position: 8
    prefix: '-F'
    valueFrom: clinvar.CLNDISDB
  - position: 8
    prefix: '-F'
    valueFrom: clinvar.CLNDISDBINCL
  - position: 8
    prefix: '-F'
    valueFrom: clinvar.CLNVC
  - position: 8
    prefix: '-F'
    valueFrom: clinvar.CLNVCSO
  - position: 8
    prefix: '-F'
    valueFrom: clinvar.CLNVI
  - position: 8
    prefix: '-F'
    valueFrom: clinvar.DBVARID
  - position: 8
    prefix: '-F'
    valueFrom: clinvar.GENEINFO
  - position: 8
    prefix: '-F'
    valueFrom: clinvar.MC
  - position: 8
    prefix: '-F'
    valueFrom: clinvar.ORIGIN
  - position: 8
    prefix: '-F'
    valueFrom: clinvar.RS
  - position: 8
    prefix: '-F'
    valueFrom: clinvar.SSR
outputs:
  - id: tableFile
    type: File
    outputBinding:
      glob: '*.table'
  - id: stdout
    type: stdout
  - id: stderr
    type: stderr
hints:
  - class: DockerRequirement
    dockerPull: 'broadinstitute/gatk:latest'
stdout: gatk.table.stdout
stderr: gatk.table.stderr
requirements:
  - class: InlineJavascriptRequirement

