#!/opt/bin/python3

"""

"""

import cgi
import json
import os
import re
#import sys

def main():
    print('Content-Type: application/json\n\n')
    
    result = { 'success':0, 'annotationsets': list() }
    annotation_base = '/home/jorvis/git/Attributor'

    #form = cgi.FieldStorage()
    #search_product = form.getvalue('search_product')

    # look for all GFF3 files under the annotation_base
    for filename in os.listdir(annotation_base):
        m = re.match('(.+)\.gff3', filename)
        if m:
            result['annotationsets'].append({'label': m.group(1), 'gene_count': 50, 'date': '2016-07-06'})
    
    result['success'] = 1
    print(json.dumps(result))
    

if __name__ == '__main__':
    main()
