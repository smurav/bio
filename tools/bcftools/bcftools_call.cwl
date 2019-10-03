class: CommandLineTool
cwlVersion: v1.0
baseCommand:
  - bcftools
  - call
  - '-mv'
  - '-Ou'
inputs:
  - id: inputFile
    type: File
    streamable: true
  - id: nthreads
    type: int
    inputBinding:
      position: 5
      prefix: '--threads'
outputs:
  - id: outputFile
    type: stdout
  - id: stderr
    type: stderr
hints:
  - class: DockerRequirement
    dockerPull: 'biocontainers/bcftools:v1.9-1-deb_cv1'
stdout: $(inputs.inputFile.nameroot + '.call.vcf')
stderr: bcftools.call.stderr
stdin: $(inputs.inputFile.path)
requirements:
  - class: InlineJavascriptRequirement
