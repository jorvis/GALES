#!/opt/bin/python3

"""
Gathers statistics for a passed FASTA file and returns them in JSON format.

This doesn't really need to be here at all, given that the view_annotation.py
script now generates it.  Keeping for now.

"""

import cgi
import json
import os
import sys

def main():
    print('Content-Type: application/json\n\n')
    
    form = cgi.FieldStorage()
    annotation_dir = form.getvalue('annotation_dir')
    fasta_file = form.getvalue('fasta_file')

    json_file_path = "{0}/fasta_stats.json".format(annotation_dir)

    # Use the existing JSON file if available.
    if os.path.exists(json_file_path):
        with open(json_file_path, 'r') as json_file:
            result = json_file.read().replace('\n', '')
            print(result)
    else:
        result = { 'success': 0 }
        print(json.dumps(result))
    

if __name__ == '__main__':
    main()
