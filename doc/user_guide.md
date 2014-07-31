User Guide to the DM2E Command Line Tools
=========================================

Setting up the environment
--------------------------

Set up the repositories:

```
cd $HOME
mkdir repo && cd repo
git clone https://github.com/DM2E/dm2e-ontologies
git clone https://github.com/DM2E/edm-validation
```

Now build and install the projects (order matters!)

```
cd $HOME/repo/dm2e-ontologies
mvn install                     # Installs the JAR into the repository
mvn package                     # creates the JARs
cd $HOME/repo/edm-validation
mvn install
```

Now install the raptor RDF library using the package manager of your choice:

```
sudo apt-get install raptor-utils   # Debian, Ubuntu
sudo pacman -S raptor               # Arch Linux
```

Install LibXSLT's xsltproc to execute XSL transformation scripts:

```
sudo apt-get install xsltproc   # Debian, Ubuntu
sudo pacman -S libxslt          # Arch Linux
```


DM2E validation
---------------

Validation of DM2E data can be executed with the following command:

```
cd $HOME/repo/dm2e-ontologies/target
java -jar dm2e-validator-jar-with-dependencies.jar --help
```

This will give you a help screen on the invocation of the tool. As of Thu Jul 31 11:21:49 CEST 2014, these options are:

```
 -format <RDF/XML | N-TRIPLE | TURTLE>                           RDF input serialization format [Default: RDF/XML]
 -level <NOTICE | WARNING | ERROR | FATAL>                       Minimum Validation level [Default: NOTICE]
 -skipOk                                                         Skip writing results for valid results
 -stdout                                                         Write to STDOUT [Default: false]
 -suffix <suffix>                                                output file suffix [default: '.validation.${model-version}.txt']
 -terse                                                          Output results very terse [Default: false]
 -version <1.1_Rev{1.2|1.3|1.4|1.5|1.6|Final} | 1.2_{RC1|RC2}>   DM2E Data Model version [REQUIRED]
```

The only required option is `-version`.

`skipOk` can be useful for large numbers of files, since only for those files that fail validation, reports will be written.

When `-terse` is given, a more dense error report is generated, containing only
the type of error (corresponding to the Enum names in
[ValidationProblemCategory](/src/main/java/eu/dm2e/validation/ValidationProblemCategory.java)
and the problematic resource/string instead of the full textual description.

You can safely ignore problems of level `NOTICE` and `WARNING`, but all data that contains `ERROR` or `FATAL` problems *should not be transformed to EDM* since the conversion is likely to fail and it is even more likely that EDM validation will fail, i.e. that the data will not be ingestible by Europeana.

dm2e-data.sh -- Interacting with DM2E data
------------------------------------------

[dm2e-data.sh](/src/main/bash/dm2e-data.sh) is a Bash script that makes it convenient to interact with the data in DM2E convenient.

It is important to note that the script *must be executed in the directory it resides*, because it uses relative paths to the various JARs. This means:

```
cd $HOME/repo/dm2e-ontologies
cd src/main/bash
bash dm2e-data.sh [...]
```

### Variables

The script uses a few global variables that can be either set when invoking the tool (see [Options](#options)) or using a profile shell script that contains only variable assignments see [Profile File](#profile_file).

The following variables can sensibly be changed:

* `IN_DIR`: The directory of the DM2E RDF/XML files
* `OUT_DIR`: The directory where the EDM converted raw RDF/XML files should be written to
* `CLEAN_DIR`: The directory where the sorted, re-serialized and Europeana-Ingestion-ready EDM RDF/XML files should be written to

The following variables can be changed but under most circumstances should not:

* `DATASET_LIST`: The path to a file containing the IRI of datasets to be extracted in the extraction step
* `SPARQL_DIR`: The directory containing
  * the [SPARQL queries](/src/main/resources/sparql-queries)
  * the [list of prefixes](/src/main/resources/sparql-queries/prefixes.rq)
  * the [sparql query bash script](/src/main/resources/sparql-queries/sparql-query.sh)


### Profile file

The profile script must be named `dm2e-data.sh` and is searched in

* the current working directory
* the $HOME directory

For example, if I have my DM2E input data in `$HOME/dm2e-in`, want the EDM output data in `/tmp/edm` and the ingestion-ready EDM files in `/data/edm-ingestion-ready`:

```
$> cat $HOME/dm2e-data.profile.sh
IN_DIR=$HOME/dm2e-in
OUT_DIR=/tmp/edm
CLEAN_DIR=/data/edm-ingestion-ready
```

### Options

As of Thu Jul 31 11:57:01 CEST 2014, the command line parameters for dm2e-data.sh are

```
    bash dm2e-data.sh <action> [options]

    Global options:
        --purge             Empty directories and list files before writing to them
        --in-dir            Set $IN_DIR
        --out-dir           Set $IN_DIR
        --clean-dir         Set $CLEAN_DIR

    Actions / options:
        list-datasets       List the latest versions of all datasets
            --dataset-list              File to write the dataset URIs to [OPTIONAL]
        list-aggregations   List the latest versions of all datasets
            --dataset/ds <URI>          URI of the dataset [REQUIRED]
        dump-aggregations   Dump the transitive closure of the list of aggregations to $IN_DIR
            --dataset/ds <URI>          URI of the dataset [REQUIRED]
        convert-to-edm      Convert the data in $IN_DIR to EDM RDF/XML in $OUT_DIR
        cleanup-edm         Transform the EDM RDF/XML in $OUT_DIR to prettier RDF/XML in $CLEAN_DIR
        batch-dump          Combines 'list-datasets', 'list-aggregations' and 'dump-aggregations'
        batch-convert       Combines 'convert-to-edm' and 'cleanup-edm'
        validate-edm        Validate the EDM RDF/XML in $OUT_DIR to prettier RDF/XML in $CLEAN_DIR

```



For the conversion to EDM, we have two assumptions:

* The data is valid against the DM2E model
* The data can be accessed using a SPARQL endpoint

The central interface to interaction with data in the DM2E triplestore and subsequent conversion/validation is in

```
$HOME/repo/dm2e-ontologies/src/main/bash/dm2e-data.sh
```

