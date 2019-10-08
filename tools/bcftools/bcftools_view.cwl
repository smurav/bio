class: CommandLineTool
cwlVersion: v1.0
baseCommand:
  - bcftools
  - view
  - '-Oz'
arguments:  
# Use -m2 -M2 -v snps to only view biallelic SNPs.
# https://gatkforums.broadinstitute.org/gatk/discussion/6696/unparsable-vcf-record-with-allele
  - position: 1
    prefix: '-m'
    valueFrom: '2'
  - position: 2
    prefix: '-M'
    valueFrom: '2'
  - position: 3
    prefix: '-v'
    valueFrom: 'snps'
  - position: 4
    prefix: '--output-file'
    valueFrom: $(inputs.inputFile.nameroot + '.filtered.vcf.gz')
inputs:
  - id: inputFile
    type: File
    inputBinding:
      position: 6
  - id: include_expression
    type: string
    inputBinding:
      position: 4
      prefix: '--include'
  - id: nthreads
    type: int
    inputBinding:
      position: 5
      prefix: '--threads'
outputs:
  - id: outputFile
    type: File
    outputBinding:
      glob: '*.filtered.vcf.gz'
  - id: stdout
    type: stdout
  - id: stderr
    type: stderr
hints:
  - class: DockerRequirement
    dockerPull: 'biocontainers/bcftools:v1.9-1-deb_cv1'
stdout: bcftools.view.stdout
stderr: bcftools.view.stderr
requirements:
  - class: InlineJavascriptRequirement
