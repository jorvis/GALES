#!/opt/bin/python3

"""
Searches the GFF3 pickle for gene product names and returns a JSON structure of the
matching genes.

"""

import cgi
import json
import os
import pickle
import sqlite3
import sys

def main():
    print('Content-Type: application/json\n\n')
    
    data_dir = "{0}/../data".format(os.path.dirname(os.path.abspath(__file__)))

    form = cgi.FieldStorage()
    gene_id = form.getvalue('gene_id')
    polypeptide_id = form.getvalue('polypeptide_id')
    features_pickle_path = "{0}/gff.stored.features.pickle".format(data_dir)
    hmm_db_path = "{0}/attributor.annotation.hmm_ev.sqlite3".format(data_dir)
    

    gene_data = {'annotation': {}, 'hmm': []}

    with open(features_pickle_path, 'rb') as feature_fh:
        features = pickle.load(feature_fh)

        # We search for it this way so it should also work with ncRNAs
        for feature_id in features:
            if feature_id == gene_id:
                gene = features[feature_id]
                polypeptides = gene.polypeptides()
                
                for polypeptide in polypeptides:
                    if polypeptide.annotation:
                        gene_data['annotation'] = {
                            'polypeptide_id': polypeptide.id,
                            'gene_locus_tag': gene.locus_tag,
                            'product': polypeptide.annotation.product_name,
                            'gene_symbol': polypeptide.annotation.gene_symbol
                        }

                # no need to keep looping over the features
                break

    try:
        hmm_db_conn = sqlite3.connect(hmm_db_path)

        hmm_cursor = hmm_db_conn.cursor()
    except sqlite3.OperationalError as e:
        raise Exception("ERROR: Failed to connect to evidence database {0} because {1}".format(hmm_db_path, e))

    qry = """
             SELECT hh.id, qry_id, qry_start, qry_end, hmm_accession, hmm_length, hmm_start, hmm_end,
                    domain_score, total_score, total_score_tc, total_score_nc, total_score_gc,
                    total_hit_eval, domain_score_tc, domain_score_nc, domain_score_gc, domain_hit_eval,
                    h.hmm_com_name, h.isotype
               FROM hmm_hit hh
                    JOIN hmm h ON hh.hmm_accession=h.version
              WHERE qry_id=?
             ORDER BY total_hit_eval ASC
          """
    hmm_cursor.execute(qry, (polypeptide_id,))

    # TODO: Find cleaner way to turn this tuple into a dict
    for (id, qry_id, qry_start, qry_end, hmm_accession, hmm_length, hmm_start, hmm_end,
         domain_score, total_score, total_score_tc, total_score_nc, total_score_gc,
         total_hit_eval, domain_score_tc, domain_score_nc, domain_score_gc, domain_hit_eval,
         hmm_com_name, isotype) in hmm_cursor:
        gene_data['hmm'].append({'hit_id':id, 'qry_id':qry_id, 'qry_start':qry_start, 'qry_end':qry_end, 'hmm_accession':hmm_accession, 
                                 'hmm_length':hmm_length, 'hmm_start':hmm_start, 'hmm_end':hmm_end, 'domain_score':domain_score, 
                                 'total_score':total_score, 'total_score_tc':total_score_tc, 'total_score_nc':total_score_nc, 
                                 'total_score_gc':total_score_gc, 'total_hit_eval':total_hit_eval, 'domain_score_tc':domain_score_tc, 
                                 'domain_score_nc':domain_score_nc, 'domain_score_gc':domain_score_gc, 'domain_hit_eval':domain_hit_eval,
                                 'hmm_com_name':hmm_com_name, 'isotype': isotype
                             })

    print(json.dumps(gene_data))

    # Close connections
    hmm_db_conn.close();
        

if __name__ == '__main__':
    main()
