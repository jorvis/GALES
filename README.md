# GALES
Genomic Annotation Logic and Execution System (GALES): Annotate a genome locally or in the cloud in minutes.

## Getting Started

These instructions describe how to get the annotation pipeline running on your machine.

### Prerequisities

The pipeline and tools are represented using [Common Workflow Language (CWL)](http://www.commonwl.org/), with all dependent tools contained within Docker images.  These two things are the only prerequisites, and are easily installed.  

#### Install [Docker](https://docs.docker.com/engine/installation/)

The Docker site has detailed [instructions](https://docs.docker.com/engine/installation/) for many architectures, but for some this may be as simple as:

```
$ sudo apt-get install docker.io
[restart]
```

If this is the first time you've installed Docker Engine, reboot your machine (even if the docs leave this step out.)

#### Install CWL

```
$ sudo pip install cwl-runner
```

### Get the pipeline

Now that you have the dependencies to run things, you need only the actual pipeline/tool CWL definitions.

```
$ git clone https://github.com/jorvis/GALES.git
```

### Running

```
$ cd GALES/cwl/workflows/
```

Here you'll find the [prok_annotation.json](https://github.com/jorvis/GALES/blob/master/cwl/workflows/prok_annotation.json) file.  Within this, you'll want to change the source_fasta.path setting and, optionally, the rapsearch2_threads and hmmscan_threads settings.

Then, you can run it like this:

```
$ ./prok_annotation.cwl prok_annotation.json
```

Once completed, the annotated GFF file will be called 'attributor.annnotation.gff3' (unless you've changed the attributor_output_base setting in the json config file.)

## Authors

See the list of [contributors](https://github.com/jorvis/GALES/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

