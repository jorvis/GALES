#!/usr/bin/env python3

"""

Starts a local HTTP server in order to visualize an annotation.

"""

import argparse
import os
from http.server import BaseHTTPRequestHandler, HTTPServer
from http.server import CGIHTTPRequestHandler
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

    exec_path = os.path.dirname(os.path.abspath(__file__))
    ui_path = "{0}/../ui".format(exec_path)
    os.chdir(ui_path)

    # Your code goes here
    run(host=server_host, port=server_port, script_args=args)

def run(host=None, port=None, script_args=None):
    args = {'annotation_dir': script_args.input_directory, 'fasta_file': script_args.fasta_file}
    args_string = urllib.parse.urlencode(args)

    initial_url = "http://{0}:{1}/index.html?{2}".format(host, port, args_string)
    print("Starting FALCONui ... at: {0}".format(initial_url))
 
    # Server settings
    # Choose port 8080, for port 80, which is normally used for a http server, you need root access
    server_address = (host, port)
    handler = CGIHTTPRequestHandler
    handler.cgi_directories = ["/cgi"]
    httpd = HTTPServer(server_address, CGIHTTPRequestHandler)
    print('running server...')

    # I couldn't get this to work.  It just opens a browser to a blank window
    #webbrowser.open_new_tab(initial_url)
    httpd.serve_forever()
    

 
    
if __name__ == '__main__':
    main()







