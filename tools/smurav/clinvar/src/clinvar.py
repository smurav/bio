#!/usr/bin/env python3

import argparse
import os
from collections import OrderedDict
import gzip
import pandas as pd

VCF_HEADER = ['CHROM', 'POS', 'ID', 'REF', 'ALT', 'QUAL', 'FILTER', 'INFO']
REPORT_COLUMNS = ['IDclinvar', 'CHROM', 'POS', 'REF', 'ALT', 'CLNSIG', 'CLNVC', 'CLNDN']

def dataframe(filename, large=True):
    """Open an optionally gzipped VCF file and return a pandas.DataFrame with
    each INFO field included as a column in the dataframe.

    Note: Using large=False with large VCF files. It will be painfully slow.

    :param filename:    An optionally gzipped VCF file.
    :param large:       Use this with large VCF files to skip the ## lines and
                        leave the INFO fields unseparated as a single column.
    """
    if large:
        # Set the proper argument if the file is compressed.
        comp = 'gzip' if filename.endswith('.gz') else None
        # Count how many comment lines should be skipped.
        comments = _count_comments(filename)
        # Return a simple DataFrame without splitting the INFO column.
        return pd.read_csv(filename, compression=comp, skiprows=comments,
                             names=VCF_HEADER, usecols=range(8), sep='\t')

    # Each column is a list stored as a value in this dict. The keys for this
    # dict are the VCF column names and the keys in the INFO column.
    result = OrderedDict()
    # Parse each line in the VCF file into a dict.
    for i, line in enumerate(lines(filename)):
        for key in line.keys():
            # This key has not been seen yet, so set it to None for all
            # previous lines.
            if key not in result:
                result[key] = [None] * i
        # Ensure this row has some value for each column.
        for key in result.keys():
            result[key].append(line.get(key, None))

    return pd.DataFrame(result)



def lines(filename):
    """Open an optionally gzipped VCF file and generate an OrderedDict for
    each line.
    """
    fn_open = gzip.open if filename.endswith('.gz') else open

    with fn_open(filename, mode='rt') as fh:
        for line in fh:
            if line.startswith('#'):
                continue
            else:
                yield parse(line)


def parse(line):
    """Parse a single VCF line and return an OrderedDict.
    """
    result = OrderedDict()

    fields = line.rstrip().split('\t')

    # Read the values in the first seven columns.
    for i, col in enumerate(VCF_HEADER[:7]):
        result[col] = _get_value(fields[i])

    # INFO field consists of "key1=value;key2=value;...".
    infos = fields[7].split(';')

    for i, info in enumerate(infos, 1):
        # info should be "key=value".
        try:
            key, value = info.split('=')
        # But sometimes it is just "value", so we'll make our own key.
        except ValueError:
            key = 'INFO{}'.format(i)
            value = info
        # Set the value to None if there is no value.
        result[key] = _get_value(value)

    return result


def _get_value(value):
    """Interpret null values and return ``None``. Return a list if the value
    contains a comma.
    """
    if not value or value in ['', '.', 'NA']:
        return None
    if ',' in value:
        return value.split(',')
    return value


def _count_comments(filename):
    """Count comment lines (those that start with "#") in an optionally
    gzipped file.

    :param filename:  An optionally gzipped file.
    """
    comments = 0  # type: int
    fn_open = gzip.open if filename.endswith('.gz') else open
    with fn_open(filename, mode='rt') as fh:
        for line in fh:
            if line.startswith('#'):
                comments += 1
            else:
                break
    return comments


def main():
    parser = argparse.ArgumentParser(description='Search for variants in clinvar database')
    parser.add_argument('sample', type=str, help='sample.vcf')
    parser.add_argument('clinvar', type=str, help='clinvar.vcf')
    args = parser.parse_args()
    sample = dataframe(args.sample, True)
    index = sample[sample['ID'] == '.'].index
    sample.drop(index, inplace=True)
    sample['RS'] = sample['ID'].str[2:]
    sample.set_index('RS', inplace=True)
    
    clinvar = dataframe(args.clinvar, False)
    print('В файле {0} описано {1} вариантов'.format(args.clinvar, len(clinvar.index)))
    clinvar.set_index('RS', inplace=True)
    result = clinvar.join(sample, how='inner', lsuffix='clinvar')
    full_len = len(result.index)
    print('В файле {0} найдено соответствие {1} идентификаторов вариантов из баз dbSNP и ClinVar'.\
          format(args.sample, full_len))

    ref = result.loc[result.REFclinvar == result.REF]
    ref_len = len(ref.index)
    if (ref_len < full_len):
        print('Отфильтровано {0} вариантов из-за несовпадения значений поля REF'. \
              format(full_len-ref_len))
        
    alt = ref.loc[ref.ALTclinvar == ref.ALT]
    alt_len = len(alt.index)
    if (alt_len < ref_len):
        print('Отфильтровано {0} вариантов из-за несовпадения значений поля ALT'. \
              format(ref_len-alt_len))
    
    full_filename = os.path.splitext(args.sample)[0] + ".all.csv"
    result.to_csv(full_filename, sep='\t', encoding='utf-8')
    
    pathogenic = alt.loc[alt['CLNSIG'].astype(str).str.contains('Pathogenic')]
    print('Патогенных вариантов: {}'.format(len(pathogenic.index)))
    pathogenic_filename = os.path.splitext(args.sample)[0] + ".pathogenic.csv"
    pathogenic[REPORT_COLUMNS].to_csv(pathogenic_filename, sep='\t', encoding='utf-8')

    likely_pathogenic = alt.loc[alt['CLNSIG'].astype(str).str.contains('Likely_pathogenic')]
    print('Вероятно патогенных вариантов: {}'.format(len(likely_pathogenic.index)))
    likely_pathogenic_filename = os.path.splitext(args.sample)[0] + ".likely_pathogenic.csv"
    likely_pathogenic[REPORT_COLUMNS].to_csv(likely_pathogenic_filename, sep='\t', encoding='utf-8')

    risk_factors = alt.loc[alt['CLNSIG'].astype(str).str.contains('risk_factor')]
    print('Факторы риска: {}'.format(len(risk_factors.index)))
    risk_factors_filename = os.path.splitext(args.sample)[0] + ".risk_factors.csv"
    risk_factors[REPORT_COLUMNS].to_csv(risk_factors_filename, sep='\t', encoding='utf-8')

if __name__ == "__main__":
    main()
