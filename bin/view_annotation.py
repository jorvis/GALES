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
import os
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

    exec_path = os.path.dirname(os.path.abspath(__file__))
    ui_path = "{0}/../ui".format(exec_path)
    os.chdir(ui_path)

    print("\n--------------------------------------------------------------------------------")
    print("Checking for stored statistics within input directory, or creating them.")
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







