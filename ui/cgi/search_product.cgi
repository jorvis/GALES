#!/opt/bin/python3

"""
Searches the GFF3 pickle for gene product names and returns a JSON structure of the
matching genes.

"""

import cgi
import json
import os
import pickle
import sys

def main():
    print('Content-Type: application/json\n\n')
    
    data_dir = "{0}/../data".format(os.path.dirname(os.path.abspath(__file__)))

    form = cgi.FieldStorage()
    search_str = form.getvalue('search_str')
    print("search_str: {0}".format(search_str), file=sys.stderr)
    assembly_pickle_path = "{0}/gff.stored.assemblies.pickle".format(data_dir)

    matches = list()

    with open(assembly_pickle_path, 'rb') as feature_fh:
        assemblies = pickle.load(feature_fh)

        for asm_id in assemblies:
            for gene in assemblies[asm_id].genes():
                polypeptides = gene.polypeptides()
                
                for polypeptide in polypeptides:
                    if polypeptide.annotation:
                        if search_str.lower() in polypeptide.annotation.product_name.lower():
                            matches.append({'id': polypeptide.id, 'gene_id': gene.id, 
                                            'gene_locus_tag': gene.locus_tag,
                                            'product': polypeptide.annotation.product_name,
                                            'gene_symbol': polypeptide.annotation.gene_symbol
                            })
                
    print(json.dumps(matches))
        

if __name__ == '__main__':
    main()
