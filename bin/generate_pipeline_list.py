#!/usr/bin/env python3

"""

Custom utility script, may not be of general use.

--input_directory

This should contain directories like this:

   AAVL00000000  ABFX00000000  ABWZ00000000  ACAA00000000

Each should have a file called 'accessions.fasta' within it.

--output_directory

A subdirectory will be created here with the same name as the corresponding input director,
within which all annotation files will be written.

This script only creates a shell script file, it doesn't actually run anything.
"""

import argparse
import os


def main():
    parser = argparse.ArgumentParser( description='Utility script which creates a shell script to run multiple pipelines.')
    parser.add_argument('-i', '--input_directory', type=str, required=True, help='Path where sample directories are found' )
    parser.add_argument('-o', '--output_directory', type=str, required=True, help='Path to base directory for output' )
    args = parser.parse_args()

    run_script = "/home/jorvis/GALES/bin/run_prok_pipeline"
    pipeline_version = 'cheetah'
    core_count = 4
    ref_directory = '/dbs'
    output_bucket = 'dacc-refgenomes-output'

    for thing in os.listdir(args.input_directory):
        sample_dir = "{0}/{1}".format(args.input_directory, thing)
        if os.path.isdir(sample_dir):
            output_dir = "{0}/{1}".format(args.output_directory, thing)

            print('echo "Running sample {0}"'.format(thing))
            print("mkdir {0}".format(output_dir))
            print("{0} -i {1}/accessions.fasta -od {2} -v {3} -rd {4} -t {5}".format(
                run_script, sample_dir, output_dir, pipeline_version, ref_directory, core_count))
            print("gsutil cp -r {1} gs://{0}\n".format(output_bucket, output_dir))


if __name__ == '__main__':
    main()







