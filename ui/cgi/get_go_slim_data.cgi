#!/opt/bin/python3

"""
Gathers statistics for a passed annotation directory and returns them in JSON format

This doesn't really need to be here at all, given that the view_annotation.py
script now generates it.  Keeping for now.

"""

import cgi
import json
import igraph
import os

def main():
    print('Content-Type: application/json\n\n')
    
    form = cgi.FieldStorage()
    annotation_dir = form.getvalue('annotation_dir')
    namespace = form.getvalue('namespace')

    annotation_dir = '/home/jorvis/git/GALES/cwl/workflows/e_coli.char.93k'
    namespace = 'cellular_component'

    ns_file_path = "{0}/obo.graphs.{1}".format(annotation_dir, namespace)
    ns_file_path = "{0}/obo.graphs.{1}".format(annotation_dir, 'terms')

    # Use the existing JSON file if available
    if os.path.exists(ns_file_path):
        result = { 'success': 1 }
        g =  igraph.Graph.Read_Pickle(fname=ns_file_path)
        for att in g:
            print("{0} -- {1}".format(att, g[att]))

    else:
        result = { 'success': 0 }
        print(json.dumps(result))
    

if __name__ == '__main__':
    main()
