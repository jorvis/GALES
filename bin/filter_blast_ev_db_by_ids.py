#!/usr/bin/env python3

"""
These are defined by: http://www.uniprot.org/help/fasta-headers

OUTPUT

The following tables are created in the SQLite3 db (which is created if it doesn't
already exist) (these are fake example data, and there are a lot of 1:many 
relationships here):

table: entry
----------
id = 001R_FRG3G
full_name = 11S globulin subunit beta
organism = Frog virus 3 (isolate Goorha)
symbol = FV3-001R

entry_acc
-----------------
id = 001R_FRG3G
accession = Q6GZX4
res_length = 121
is_characterized = 1

entry_go
----------------
id = 001R_FRG3G
go_id = string (0005634)

entry_ec
----------------
id = 001R_FRG3G
ec_num = 6.3.4.3

"""


import argparse
import os
import re
import sqlite3

pfam2go = dict()

def main():
    parser = argparse.ArgumentParser( description='Reads a uniprot_sprot.dat file and creates a SQLite3 database of commonly-accessed attributes for each accession.')

    ## output file to be written
    parser.add_argument('-id', '--input_db', type=str, required=True, help='Path to the input source SQLite3 db file.' )
    parser.add_argument('-od', '--output_db', type=str, required=True, help='Path to an output SQLite3 db to be created' )
    parser.add_argument('-i', '--input_id_file', type=str, required=True, help="Path to a file with one access on each line")
    args = parser.parse_args()

    # this creates it if it doesn't already exist
    src_conn = sqlite3.connect(args.input_db)
    src_curs = src_conn.cursor()
    dest_conn = sqlite3.connect(args.output_db)
    dest_curs = dest_conn.cursor()

    print("INFO: Creating tables ...")
    create_tables( dest_curs )
    dest_conn.commit()

    ids_already_loaded = dict()

    for acc in open(args.input_id_file):
        acc = acc.rstrip()
        cache_blast_hit_data(accession=acc, ref_curs=src_curs, ev_curs=dest_curs, ids_loaded=ids_already_loaded)
            
    dest_conn.commit()

    print("INFO: Creating indexes ...")
    create_indexes(dest_curs)
    dest_conn.commit()
    src_curs.close()
    dest_curs.close()
    print("INFO: Complete.")
    

def cache_blast_hit_data(accession=None, ref_curs=None, ev_curs=None, ids_loaded=None):
    """
    Gets annotation for a specific accession and copies its entry from the large source index into
    our smaller hits-found-only evidence index.
    """
    ref_blast_select_qry = """
       SELECT e.id, e.full_name, e.organism, e.symbol, ea.accession, ea.res_length, ea.is_characterized
         FROM entry e 
              JOIN entry_acc ea on ea.id=e.id
         WHERE ea.accession = ?
    """

    ev_blast_insert_qry = "INSERT INTO entry (id, full_name, organism, symbol) VALUES (?, ?, ?, ?)"
    ev_acc_insert_qry  = "INSERT INTO entry_acc (id, accession, res_length, is_characterized) VALUES (?, ?, ?, ?)"

    ref_go_select_qry = "SELECT id, go_id FROM entry_go WHERE id = ?"
    ev_go_insert_qry  = "INSERT INTO entry_go (id, go_id) VALUES (?, ?)"

    ref_ec_select_qry = "SELECT id, ec_num FROM entry_ec WHERE id = ?"
    ev_ec_insert_qry  = "INSERT INTO entry_ec (id, ec_num) VALUES (?, ?)"

    ref_curs.execute(ref_blast_select_qry, (accession,))
    entry_row = ref_curs.fetchone()
    if entry_row is not None:
        entry_id = entry_row[0]

        if entry_id not in ids_loaded:
            ev_curs.execute(ev_blast_insert_qry, (accession, entry_row[1], entry_row[2], entry_row[3]))

        ev_curs.execute(ev_acc_insert_qry, (accession, entry_row[4], entry_row[5], entry_row[6]))

        ref_curs.execute(ref_go_select_qry, (accession,))
        for go_row in ref_curs:
            ev_curs.execute(ev_go_insert_qry, (accession, go_row[1]))

        ref_curs.execute(ref_ec_select_qry, (accession,))
        for ec_row in ref_curs:
            ev_curs.execute(ev_ec_insert_qry, (accession, ec_row[1]))

        ids_loaded[entry_id] = True

def create_indexes( cursor ):
    # CREATE INDEX index_name ON table_name (column_name);

    cursor.execute("CREATE INDEX idx_col_us_id  ON entry (id)")

    cursor.execute("CREATE INDEX idx_col_usa_id  ON entry_acc (id)")
    cursor.execute("CREATE INDEX idx_col_usa_acc ON entry_acc (accession)")
    
    cursor.execute("CREATE INDEX idx_col_usg_id ON entry_go (id)")
    cursor.execute("CREATE INDEX idx_col_usg_go ON entry_go (go_id)")

    cursor.execute("CREATE INDEX idx_col_use_id ON entry_ec (id)")
    cursor.execute("CREATE INDEX idx_col_use_ec ON entry_ec (ec_num)")


def create_tables( cursor ):
    cursor.execute("""
              CREATE TABLE entry (
                 id                text primary key,
                 full_name         text,
                 organism          text,
                 symbol            text
              )
    """)
    
    cursor.execute("""
              CREATE TABLE entry_acc (
                 id         text not NULL,
                 accession  text not NULL,
                 res_length INT,
                 is_characterized integer DEFAULT 0
              )
    """)
    
    cursor.execute("""
              CREATE TABLE entry_go (
                 id     text not NULL,
                 go_id  text not NULL
              )
    """)

    cursor.execute("""
              CREATE TABLE entry_ec (
                 id     text not NULL,
                 ec_num text not NULL
              )
    """)


if __name__ == '__main__':
    main()







