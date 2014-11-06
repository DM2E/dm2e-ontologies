#!/bin/bash

SCRIPT_DIR=$(dirname $(readlink -f $0))
PROJECT_ROOT=$(readlink -f $SCRIPT_DIR/..)
BUILD_DIR=$PROJECT_ROOT/target/dm2edata-1.0

create_directory_structure() {
    mkdir -p $BUILD_DIR
    mkdir -p $BUILD_DIR/etc
    mkdir -p $BUILD_DIR/usr/share/dm2edata/
    mkdir -p $BUILD_DIR/usr/share/dm2edata/sparql-queries
    mkdir -p $BUILD_DIR/usr/bin
}

copy_files() {

    # Debian packaging info
    cp -r $PROJECT_ROOT/dist/debian $BUILD_DIR

    # Default profile
    cp $PROJECT_ROOT/src/main/bash/dm2e-data.profile.SYSTEM.sh $BUILD_DIR/etc/dm2e-data.profile.sh

    # Shell scripts
    cp $PROJECT_ROOT/src/main/bash/dm2e-data.sh $BUILD_DIR/usr/bin/dm2e-data
    cp $PROJECT_ROOT/src/main/resources/sparql-queries/sparql-query.sh $BUILD_DIR/usr/bin/sparql-query
    cp $PROJECT_ROOT/src/main/bash/ntriplify-folder.sh $BUILD_DIR/usr/bin/ntriplify-folder

    # SPARQL queries
    cp $PROJECT_ROOT/src/main/resources/sparql-queries/*.rq $BUILD_DIR/usr/share/dm2edata/sparql-queries

    # XSLT sort script
    cp $PROJECT_ROOT/src/main/resources/sparql-queries/sort.xsl $BUILD_DIR/usr/share/dm2edata/sort.xsl

    # JARs
    cp $PROJECT_ROOT/target/dm2e-edm-jar-with-dependencies.jar $BUILD_DIR/usr/share/dm2edata/dm2e-edm.jar
    cp $PROJECT_ROOT/target/edm-validator-jar-with-dependencies.jar $BUILD_DIR/usr/share/dm2edata/edm-validation.jar

}

package() {
    cd $BUILD_DIR
    echo $BUILD_DIR
    dpkg-buildpackage
}

create_directory_structure
copy_files
package
