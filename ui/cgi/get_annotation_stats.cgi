#!/opt/bin/python3

"""
Gathers statistics for a passed annotation directory and returns them in JSON format

It checks the annotation_dir directory passed for files called:

  attributor.annotation.gff3

It looks first for a file called gff_stats.json and uses that if present.  If not 
present, it writes one so that future executions will be faster.

"""

import cgi
import biocodegff
import biocodeutils
import json
import os

def main():
    print('Content-Type: application/json\n\n')
    
    form = cgi.FieldStorage()
    annotation_dir = form.getvalue('annotation_dir')
    fasta_file = form.getvalue('fasta_file')

    json_file_path = "{0}/gff_stats.json".format(annotation_dir)
    gene_length_sum = 0

    # Use the existing JSON file if available.
    if os.path.exists(json_file_path):
        with open('json_file_path', 'r') as json_file:
            result = json_file.read().replace('\n', '')
    else:
        result = { 'success': 0, 'stats_gene_count': 0, 'stats_hypo_gene_count': 0,
                   'stats_gene_mean_length': None, 'stats_specific_annot_count': 0,
                   'stats_rRNA_count': 0, 'stats_tRNA_count': 0, 'stats_go_terms_assigned': 0,
                   'stats_ec_numbers_assigned': 0, 'stats_gene_symbols_assigned': 0,
                   'stats_dbxrefs_assigned': 0
                 }
        (assemblies, features) = biocodegff.get_gff3_features( "{0}/attributor.annotation.gff3".format(annotation_dir) )
        
        for assembly_id in assemblies:
            for gene in assemblies[assembly_id].genes():
                result['stats_gene_count'] += 1
                gene_length_sum += gene.locations[0].fmax - gene.locations[0].fmin
    
                result['stats_rRNA_count'] = len(gene.rRNAs())
                result['stats_tRNA_count'] = len(gene.tRNAs())

                ## annotation is on mRNAs
                for mRNA in gene.mRNAs():
                    for polypeptide in mRNA.polypeptides():
                        annot = polypeptide.annotation

                        if annot is not None:
                            if 'hypothetical' in annot.product_name:
                                result['stats_hypo_gene_count'] += 1
                            else:
                                result['stats_specific_annot_count'] += 1

                            result['stats_go_terms_assigned'] += len(annot.go_annotations)
                            result['stats_ec_numbers_assigned'] += len(annot.ec_numbers)
                            result['stats_dbxrefs_assigned'] += len(annot.dbxrefs)
                            
                            if annot.gene_symbol is not None:
                                result['stats_gene_symbols_assigned'] += 1

        result['stats_gene_mean_length'] = "{0:.1f}".format(gene_length_sum / result['stats_gene_count'])
        result['stats_mean_go_terms_per_gene'] = "{0:.1f}".format(result['stats_go_terms_assigned'] / result['stats_gene_count'])

    result['success'] = 1
    
    print(json.dumps(result))
    

if __name__ == '__main__':
    main()
