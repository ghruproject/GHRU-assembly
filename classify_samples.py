import sys

sample_name = sys.argv[1]
short_reads1 = sys.argv[2]
short_reads2 = sys.argv[3]
long_reads = sys.argv[4]
genome_size = sys.argv[5]

if short_reads1 != '' and short_reads2 != '':
    if long_reads != '':
        print('Hybrid')
    else:
        print('Short')
else:
    if long_reads != '':
        print('Long')
    else:
        print('Unknown')