#!/bin/bash

SCRIPT_DIR=$(dirname $(readlink -f $0))
PROJECT_ROOT=$(readlink -f $SCRIPT_DIR/..)
BUILDDIR=$SCRIPT_DIR/dm2edata-1.0

create_directory_structure() {
    mkdir -p $BUIDLDDIR/etc
    mkdir -p $BUIDLDDIR/usr/share/dm2edata/
    mkdir -p $BUIDLDDIR/usr/share/dm2edata/sparql-queries
    mkdir -p $BUIDLDDIR/bin
}

copy_files() {
    cp $PROJECT_ROOT/src/main/bash/dm2e-data.sh $BUILDDIR/bin
    cp $PROJECT_ROOT/src/main/bash/dm2e-data.sh $BUILDDIR/bin
    cp $PROJECT_ROOT/src/main/bash/dm2e-data.sh $BUILDDIR/bin
}
