#!/usr/bin/env python3

import argparse
import os
from collections import OrderedDict
import gzip
import pandas as pd

VCF_HEADER = ['CHROM', 'POS', 'ID', 'REF', 'ALT', 'QUAL', 'FILTER', 'INFO']


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

    with fn_open(filename) as fh:
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
    with fn_open(filename) as fh:
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
    pathogenic = clinvar.loc[clinvar['CLNSIG'] == 'Pathogenic'].set_index('RS').astype(str)
    print('Всего патогенных вариантов: {}'.format(len(pathogenic.index)))
    result = pathogenic.join(sample, how='inner', lsuffix='.clinvar')
    print('В файле {0} Обнаружено {1} патогенных вариантов'.format(args.sample, len(result.index)))
    res_filename = os.path.basename(args.sample) + ".pathogenic.csv"
    print('Результат записан в файл {}'.format(res_filename))
    #result.to_csv(res_filename, sep='\t', encoding='utf-8')
    result[['CHROM', 'POS', 'REF', 'ALT', 'CLNSIG', 'CLNVC', 'CLNDN', 'GENEINFO', 'CLNDISDB']].to_csv(res_filename, sep='\t', encoding='utf-8')

if __name__ == "__main__":
    main()
