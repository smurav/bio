class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
id: fastqc
baseCommand:
  - fastqc
  - '--noextract'
inputs:
  - id: read1
    type: File
    inputBinding:
      position: 1
  - id: read2
    type: File
    inputBinding:
      position: 2
outputs:
  - id: report1
    type: File
    outputBinding:
      glob: $(inputs.read1.basename + '.html')
  - id: report2
    type: File
    outputBinding:
      glob: $(inputs.read2.basename + '.html')
  - id: stdout
    type: stdout
  - id: stderr
    type: stderr
label: fastqc
requirements:
  - class: DockerRequirement
    dockerPull: 'biocontainers/fastqc:v0.11.5_cv4'
  - class: InlineJavascriptRequirement
stdout: fastqc.stdout
stderr: fastqc.stderr
