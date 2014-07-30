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

This will give you a help screen on the invocation of the tool.

For the conversion to EDM, we have two assumptions:

* The data is valid against the DM2E model
* The data can be accessed using a SPARQL endpoint


dm2e-data.sh -- doing stuff with DM2E data
------------------------------------------

The central interface to interaction with data in the DM2E triplestore and subsequent conversion/validation is in

```
$HOME/repo/dm2e-ontologies/src/main/bash/dm2e-data.sh
```

