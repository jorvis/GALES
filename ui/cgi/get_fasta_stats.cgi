#!/opt/bin/python3

"""
Gathers statistics for a passed FASTA file and returns them in FASTA format.

It checks the annotation_dir directory passed for a file called
fasta_stats.json and uses that if present.  If not present, it writes one
so that future executions will be faster.

"""

import cgi
import biocodeutils
import json
import os


def main():
    print('Content-Type: application/json\n\n')
    
    form = cgi.FieldStorage()
    annotation_dir = form.getvalue('annotation_dir')
    fasta_file = form.getvalue('fasta_file')

    json_file_path = "{0}/fasta_stats.json".format(annotation_dir)

    # Use the existing JSON file if available.
    if os.path.exists(json_file_path):
        with open('json_file_path', 'r') as json_file:
            result = json_file.read().replace('\n', '')
    else:
        result = { 'success':0, '': list() }
        fasta_dict = biocodeutils.fasta_dict_from_file(fasta_file)
        result['stats_assembly_count'] = len(fasta_dict)

        shortest = None
        longest = None
        assembly_sum_length = 0
        gc_count = 0

        for id in fasta_dict:
            
            contig_len = len(fasta_dict[id]['s'])
            assembly_sum_length += contig_len
            gc_count += fasta_dict[id]['s'].upper().count('C') + fasta_dict[id]['s'].upper().count('G')

            if shortest is None or contig_len < shortest:
                shortest = contig_len

            if longest is None or contig_len > longest:
                longest = contig_len

        result['stats_assembly_sum_length'] = assembly_sum_length
        result['stats_assembly_longest_length'] = longest
        result['stats_assembly_shortest_length'] = shortest
        result['stats_assembly_gc'] = "{0:.1f}%".format((gc_count / assembly_sum_length) * 100)
        
    result['success'] = 1
    
    print(json.dumps(result))
    

if __name__ == '__main__':
    main()
