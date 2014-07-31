How to convert DM2E data to EDM
===============================

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

dm2e-data.sh -- Interacting with DM2E data
------------------------------------------

dm2e-data.sh is a Bash script that makes interacting with the data in DM2E convenient on the command line.

For the conversion to EDM, we have two assumptions:

* The data is valid against the DM2E model
* The data can be accessed using a SPARQL endpoint

The central interface to interaction with data in the DM2E triplestore and subsequent conversion/validation is in

```
$HOME/repo/dm2e-ontologies/src/main/bash/dm2e-data.sh
```

