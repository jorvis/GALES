#!/usr/bin/env python3

"""

Starts a local HTTP server in order to visualize an annotation.

Performs the following computes on first execution, saving files
within the --input_directory so that these don't have to be re-run
on future executions:

1. Parse the FASTA file for molecule statistics
2. Parse the GFF file for basic annotation statistics
3. Perform a GO slim mapping

"""

import argparse
import biocodeutils
import biocodegff
from http.server import BaseHTTPRequestHandler, HTTPServer
from http.server import CGIHTTPRequestHandler
import json
import igraph
import os
import pickle
import re
import sys
import urllib.parse
import webbrowser

def main():
    parser = argparse.ArgumentParser( description='Visualize a FALCON annotation')

    ## output file to be written
    parser.add_argument('-i', '--input_directory', type=str, required=True, help='Path to a directory containing the FALCON results' )
    parser.add_argument('-f', '--fasta_file', type=str, required=True, help='Path to the FASTA file that was input to FALCON' )
    parser.add_argument('-p', '--port', type=int, required=False, default=8081, help='Port on which you want to run the web server' )
    args = parser.parse_args()

    server_host = '127.0.0.1'
    server_port = args.port

    # we need to be dealing with full paths
    args.input_directory = os.path.abspath(args.input_directory)
    args.fasta_file = os.path.abspath(args.fasta_file)
    gff_file = "{0}/attributor.annotation.gff3".format(args.input_directory)
    fasta_stats_file = "{0}/fasta_stats.json".format(args.input_directory)
    gff_stats_file = "{0}/gff_stats.json".format(args.input_directory)

    # base name of the pickled graph files
    go_graph_base = "{0}/obo.graphs".format(args.input_directory)

    exec_path = os.path.dirname(os.path.abspath(__file__))
    obo_file = "{0}/../data/go.obo".format(exec_path)
    ui_path = "{0}/../ui".format(exec_path)
    os.chdir(ui_path)

    print("\n--------------------------------------------------------------------------------")
    print("Checking for stored statistics and analyses within input directory, or creating them.")
    print("This can cause the first execution on any input directory to take a few minutes.")
    print("--------------------------------------------------------------------------------\n")

    if os.path.exists(fasta_stats_file):
        print("Checking for FASTA stats file ... found.", flush=True)
    else:
        print("Checking for FASTA stats file ... not found.  Parsing ... ", end='', flush=True)
        generate_fasta_stats(fasta_file=args.fasta_file, json_out=fasta_stats_file)
        print("done.", flush=True)

    if os.path.exists(gff_stats_file):
        print("Checking for GFF stats file ... found.", flush=True)
    else:
        print("Checking for GFF stats file ... not found.  Parsing ... ", end='', flush=True)
        generate_gff_stats(gff_file=gff_file, json_out=gff_stats_file)
        print("done.", flush=True)

    # A bit more complicated, this function checks for the different stored ontology graphs
    print("Checking for parsed OBO graphs ... ", flush=True, end='')
    terms, g = parse_obo_graph(go_graph_base=go_graph_base, obo_file=obo_file)
    print("done.", flush=True)

    run(host=server_host, port=server_port, script_args=args)

    
def generate_fasta_stats(fasta_file=None, json_out=None):
    result = { 'success': 0 }
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

    with open(json_out, 'w') as outfile:
        json.dump(result, outfile)


def generate_gff_stats(gff_file=None, json_out=None):
    result = { 'success': 1, 'stats_gene_count': 0, 'stats_hypo_gene_count': 0,
               'stats_gene_mean_length': None, 'stats_specific_annot_count': 0,
               'stats_rRNA_count': 0, 'stats_tRNA_count': 0, 'stats_go_terms_assigned': 0,
               'stats_ec_numbers_assigned': 0, 'stats_gene_symbols_assigned': 0,
               'stats_dbxrefs_assigned': 0
             }
    (assemblies, features) = biocodegff.get_gff3_features(gff_file)
    gene_length_sum = 0

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
    
    with open(json_out, 'w') as outfile:
        json.dump(result, outfile)


def parse_obo_graph(go_graph_base=None, obo_file=None):
    stored_pickle_file_prefix = go_graph_base
    stored_pickles_found = False

    g = {'biological_process': igraph.Graph(directed=True), 
         'cellular_component': igraph.Graph(directed=True),
         'molecular_function': igraph.Graph(directed=True) }

    for ns in g:
        pickle_file_path = "{0}.{1}".format(stored_pickle_file_prefix, ns)
        if os.path.exists(pickle_file_path):
            g[ns] = igraph.Graph.Read_Pickle(fname=pickle_file_path)
            stored_pickles_found = True

    # key: GO:ID, value = {'ns': 'biological_process', 'idx': 25}
    terms = dict()

    if stored_pickles_found is True:
        with open("{0}.terms".format(stored_pickle_file_prefix), 'rb') as f:
            terms = pickle.load(f)

        print("done.", flush=True)
    else:
        print("not found. Parsing ... ", flush=True)

    # key: namespace, value=int
    next_idx = {'biological_process': 0, 
                'cellular_component': 0,
                'molecular_function': 0 }

    id = None
    namespace = None
    name = None

    # Pass through the file once just to get all the GO terms and their namespaces
    #  This makes the full pass far easier, since terms can be referenced which haven't
    #  been seen yet.

    if stored_pickles_found is False:
        for line in open(obo_file):
            line = line.rstrip()
            if line.startswith('[Term]'):
                if id is not None:
                    # error checking
                    if namespace is None:
                        raise Exception("Didn't find a namespace for term {0}".format(id))

                    g[namespace].add_vertices(1)
                    idx = next_idx[namespace]
                    g[namespace].vs[idx]['id'] = id
                    g[namespace].vs[idx]['name'] = name
                    next_idx[namespace] += 1
                    terms[id] = {'ns': namespace, 'idx': idx}

                # reset for next term
                id = None
                namespace = None
                name = None

            elif line.startswith('id:'):
                id = line.split(' ')[1]

            elif line.startswith('namespace:'):
                namespace = line.split(' ')[1]
                
            elif line.startswith('name:'):
                m = re.match('name: (.+)', line)
                if m:
                    name = m.group(1).rstrip()
                else:
                    raise Exception("Failed to regex this line: {0}".format(line))
    
    id = None
    alt_ids = list()
    namespace = None
    name = None
    is_obsolete = False
    is_a = list()

    # Now actually parse the rest of the properties
    if stored_pickles_found is False:
        for line in open(obo_file):
            line = line.rstrip()
            if line.startswith('[Term]'):
                if id is not None:
                    # make any edges in the graph
                    for is_a_id in is_a:
                        # these two terms should be in the same namespace
                        if terms[id]['ns'] != terms[is_a_id]['ns']:
                            raise Exception("is_a relationship found with terms in different namespaces")

                        #g[namespace].add_edges([(terms[id]['idx'], terms[is_a_id]['idx']), ])
                        # the line above is supposed to be able to instead be this, according to the 
                        # documentation, but it fails:
                        g[namespace].add_edge(terms[id]['idx'], terms[is_a_id]['idx'])

                # reset for this term
                id = None
                alt_ids = list()
                namespace = None
                is_obsolete = False
                is_a = list()

            elif line.startswith('id:'):
                id = line.split(' ')[1]
  
            elif line.startswith('namespace:'):
                namespace = line.split(' ')[1]

            elif line.startswith('is_a:'):
                is_a.append(line.split(' ')[1])

    if stored_pickles_found is False:
        for ns in g:
            pickle_file_path = "{0}.{1}".format(stored_pickle_file_prefix, ns)
            g[ns].write_pickle(fname=pickle_file_path)

        ## save the terms too so we don't have to redo that parse
        with open("{0}.terms".format(stored_pickle_file_prefix), 'wb') as f:
            pickle.dump(terms, f, pickle.HIGHEST_PROTOCOL)

    return terms, g

        
def run(host=None, port=None, script_args=None):
    args = {'annotation_dir': script_args.input_directory, 'fasta_file': script_args.fasta_file}
    args_string = urllib.parse.urlencode(args)

    initial_url = "http://{0}:{1}/index.html?{2}".format(host, port, args_string)
    print("Starting FALCONui server.  Open your browser to the following URL:\n\n{0}".format(initial_url), flush=True)
 
    # Server settings
    # Choose port 8080, for port 80, which is normally used for a http server, you need root access
    server_address = (host, port)
    handler = CGIHTTPRequestHandler
    handler.cgi_directories = ["/cgi"]
    httpd = HTTPServer(server_address, CGIHTTPRequestHandler)

    # I couldn't get this to work.  It just opens a browser to a blank window
    #webbrowser.open_new_tab(initial_url)
    httpd.serve_forever()
    

 
    
if __name__ == '__main__':
    main()







