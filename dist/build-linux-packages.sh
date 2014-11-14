#!/bin/bash

SCRIPT_DIR=$(dirname $(readlink -f $0))
PROJECT_ROOT=$(readlink -f $SCRIPT_DIR/..)
BUILD_DIR=$PROJECT_ROOT/target/dm2edata-1.0

which fpm 2> /dev/null || {
    echo "fpm is not installed."
    echo "Get it from https://github.com/jordansissel/fpm"
    exit
}

create_directory_structure() {
    rm -r $BUILD_DIR
    mkdir -p $BUILD_DIR
    mkdir -p $BUILD_DIR/etc
    mkdir -p $BUILD_DIR/usr/share/dm2edata/
    mkdir -p $BUILD_DIR/usr/share/dm2edata/sparql-queries
    mkdir -p $BUILD_DIR/usr/bin
}

copy_files() {

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
    cp $PROJECT_ROOT/../edm-validation/target/edm-validation-jar-with-dependencies.jar $BUILD_DIR/usr/share/dm2edata/edm-validation.jar

}

package_debian() {
    cd $PROJECT_ROOT/target

    echo "############################################"
    echo "# Build for Debian                         #"
    echo "############################################"
    fpm -t deb \
        -f \
        -s dir -n dm2edata \
        -d "openjdk-7-jre" \
        -d "raptor-utils (>= 1.4.21)" \
        -d "parallel (>= 20121122)" \
        -d "xsltproc" \
        -d "libsaxonb-java" \
        -d "coreutils" \
        -d "bash (>= 4)" \
        -d "curl" \
        $BUILD_DIR
}

package_redhat() {
    create_directory_structure
    copy_files
    cd $PROJECT_ROOT/target
    echo "############################################"
    echo "# Build for CentOS / RedHat / SUSE         #"
    echo "############################################"

    if [[ ! -e "parallel-20141022-2.1.noarch.rpm" ]];then
        echo "Downloading required gnu parallel RPM"
        wget "http://download.opensuse.org/repositories/home:/tange/CentOS_CentOS-6/noarch/parallel-20141022-2.1.noarch.rpm"
    fi

    cd $BUILD_DIR
    fpm -t rpm \
        -f \
        -s dir -n dm2edata \
        -d "java-1.7.0-openjdk" \
        -d "raptor2" \
        -d "parallel" \
        -d "libxslt" \
        -d "bash" \
        -d "curl" \
        -d "saxon-scripts" \
        .
    mv *rpm ..
    cd ..
    zip dm2edata-rpm.zip *rpm
}

package_debian
package_redhat
