class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
id: fastp
baseCommand:
  - fastp
inputs:
  - id: sample
    type: string
    label: Идентификатор образца
  - id: data_dir
    type: Directory
    label: Каталог с исходными данными
  - id: custom_args
    type: string?
    inputBinding:
      position: 11
      shellQuote: false
    label: Additional options
  - id: adapter1
    type: string?
    inputBinding:
      position: 10
      prefix: '--adapter_sequence='
      separate: false
  - id: adapter2
    type: string?
    inputBinding:
      position: 10
      prefix: '--adapter_sequence_r2='
      separate: false
  - id: nthreads
    type: int
outputs:
  - id: out1_cleaned_fq
    label: Cleaned forward read
    type: File
    outputBinding:
      glob: $(inputs.sample + '_R1.cleaned')
    'sbg:fileTypes': FastQ
  - id: out1_unpaired_fq
    label: Unpaired forward read
    type: File
    outputBinding:
      glob: $(inputs.sample + '_R1.unpaired')
    'sbg:fileTypes': FastQ
  - id: out2_cleaned_fq
    label: Cleaned reverse read
    type: File
    outputBinding:
      glob: $(inputs.sample + '_R2.cleaned')
    'sbg:fileTypes': FastQ
  - id: out2_unpaired_fq
    label: Unpaired reverse read
    type: File
    outputBinding:
      glob: $(inputs.sample + '_R2.unpaired')
    'sbg:fileTypes': FastQ
  - id: report_json
    label: Report in json file
    type: File
    outputBinding:
      glob: $(inputs.sample + '.html')
  - id: report_html
    label: Report in html file
    type: File
    outputBinding:
      glob: $(inputs.sample + '.html')
  - id: stdout
    type: stdout
  - id: stderr
    type: stderr
label: fastp
arguments:
  - position: 0
    prefix: '-w'
    valueFrom: $(inputs.nthreads)
  - position: 1
    prefix: '--in1'
    valueFrom: $(inputs.data_dir.path)/$(inputs.sample + '_R1_001.fastq.gz')
  - position: 3
    prefix: '--in2'
    valueFrom: $(inputs.data_dir.path)/$(inputs.sample + '_R2_001.fastq.gz')  
  - position: 2
    prefix: '--out1'
    valueFrom: $(inputs.sample + '_R1.cleaned')
  - position: 4
    prefix: '--out2'
    valueFrom: $(inputs.sample + '_R2.cleaned')
  - position: 5
    prefix: '--unpaired1'
    valueFrom: $(inputs.sample + '_R1.unpaired')
  - position: 6
    prefix: '--unpaired2'
    valueFrom: $(inputs.sample + '_R2.unpaired')
  - position: 7
    prefix: '--json'
    valueFrom: $(inputs.sample + '.json')
  - position: 8
    prefix: '--html'
    valueFrom: $(inputs.sample + '.html')
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    coresMax: 7
  - class: ResourceRequirement
    coresMin: 0
  - class: DockerRequirement
    dockerPull: 'pgcbioinfo/fastp:0.20.0'
  - class: InlineJavascriptRequirement
    
stdout: fastp.stdout
stderr: fastp.stderr
