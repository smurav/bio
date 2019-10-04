class: ExpressionTool
cwlVersion: v1.0

inputs:
  bam: File
  bai: File

outputs:
  bam_with_index:
    type: File
    secondaryFiles: $(inputs.bai)
expression: >
        ${
        var ret = inputs.bam;
        ret["secondaryFiles"] = [
            inputs.bai,
        ];
        return { "bam_with_index": ret } ; }
requirements:
  - class: InlineJavascriptRequirement
