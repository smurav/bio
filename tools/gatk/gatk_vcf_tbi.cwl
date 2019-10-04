class: ExpressionTool
cwlVersion: v1.0

inputs:
  vcf: File
  tbi: File

outputs:
  vcf_with_index:
    type: File
    secondaryFiles: .tbi
expression: >
        ${
        var ret = inputs.vcf;
        ret["secondaryFiles"] = [
            inputs.tbi,
        ];
        return { "vcf_with_index": ret } ; }
