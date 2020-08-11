# GALES
Genomic Annotation Logic and Execution System (GALES): Annotate a genome locally or in the cloud in minutes.

## Getting Started

These instructions describe how to get an annotation pipeline running on your machine.  The current version contains
a functional prokaryotic pipeline with both metagenomic and eukaryotic coming next.  You can test run the
prok-cheetah pipeline now, and please file issue tickets if you encounter any errors or if anything is unclear.

The setup instructions below are for Ubuntu 18.04 LTS, but you can adjust as necessary for your OS.

### Prerequisities

The pipeline and tools are represented using [Common Workflow Language (CWL)](http://www.commonwl.org/), with all dependent tools contained within Docker images.  These two things are the only prerequisites, and are easily installed.  

#### Install [Docker](https://docs.docker.com/engine/installation/) and pre-requisites

The Docker site has detailed [instructions](https://docs.docker.com/engine/installation/) for many architectures, but for some this may be as simple as:

```
$ sudo apt-get install docker.io python3 python3-pip python-pip zlib1g-dev libxml2-dev
$ sudo usermod -aG docker $USER
[restart]
```

If you get an error there about python-pip not being found, you probably need to [enable the universe repository](https://itsfoss.com/ubuntu-repositories/).

If this is the first time you've installed Docker Engine, reboot your machine (even if the docs leave this step out.)

#### Install CWL

```
$ sudo pip install cwlref-runner
```

#### Install igraph (OS X only)

```
$ brew install igraph
```

#### Install python modules

The [Biocode](https://github.com/jorvis/biocode) scripts and libraries are used within GALES.  Note that
biocode uses Python3, so the version of pip called is pip3.

```
$ sudo pip3 install biocode jinja2
```

### Get GALES

Now that you have the dependencies to run things, you need only the actual pipeline/tool CWL definitions.

```
$ git clone https://github.com/jorvis/GALES.git
```

### Getting reference data

The pipelines depend on reference data against which searches will be performed.  These only need to
be downloaded once but can be large depending on the version of the pipeline you use.  As an example,
let's walk through running the 'cheetah' version of the prokaryotic annotation pipeline, which is the
fastest and uses the smallest datasets.

```
$ cd GALES/bin
$ sudo mkdir /dbs
$ sudo chown $USER /dbs
$ ./download_reference_data -rd /dbs -p prok-cheetah
```

I put my reference collection in /dbs (you can choose another directory), and this tells the script to
search for any I don't have yet and place them there.

### Running

There are launchers for the different pipelines, which will check your system before running.

```
$ ./run_prok_pipeline -i ../test_data/genomes/E_coli_k12_dh10b.fna -od /tmp/demo -v cheetah -rd /dbs
```

Once completed, the annotated GFF file will be called 'attributor.annotation.gff3', along with many other
files representing the evidence involved in generating the annotation.

### Visualization

This is very experimental and under active development, but you can create a web interface to view the
results of your annotation and evidence graphically like this:

```
$ ./view_annotation -i /tmp/demo -f ../test_data/genomes/E_coli_k12_dh10b.fna
```

This will parse the database, generate a GO-slim mapping, and provide a local URL where you can view
the browser.

## Authors

See the list of [contributors](https://github.com/jorvis/GALES/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

