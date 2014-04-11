#!/bin/bash

ontology=../dm2e-model/DM2Ev1.1_Rev1.6.owl
ontology_tempfile=/tmp/dm2e.nt
ontology_datatype_properties=/tmp/dm2e-datatypes.lst
ontology_object_properties=/tmp/dm2e-object.lst
ontology_classes=/tmp/dm2e-class.lst
dumpDir=/data/datasets/

SUFFIX_DATATYPE="datatype_property.count.txt"

create_lists() {
    rapper -i rdfxml -o ntriples $ontology > $ontology_tempfile
    grep 'http://www.w3.org/2002/07/owl#DatatypeProperty' $ontology_tempfile \
        |grep -o '^<[^>]\+>' |sed 's/[<>]//g' \
        > $ontology_datatype_properties
    grep 'http://www.w3.org/2002/07/owl#ObjectProperty' $ontology_tempfile \
        |grep -o '^<[^>]\+>' |sed 's/[<>]//g' \
        > $ontology_object_properties
    grep 'http://www.w3.org/2002/07/owl#Class' $ontology_tempfile \
        |grep -o '^<[^>]\+>' |sed 's/[<>]//g' \
        > $ontology_classes
}

count_ontology_elements() {
    local dataset=$1
    local objectOrDatatypeOrClass=$2
    local outfile=$dataset.$SUFFIX_DATATYPE;
    echo > $outfile
    for prop in $(cat $ontology_datatype_properties);do
        echo -ne "\r -> Counting Datatype properties [$prop]                 "
        echo "$prop  $(grep "$prop" $dataset |wc -l)" >> $outfile;
    done
}

count_object_properties() {
    local dataset=$1

}

create_lists

for dataset in $*;do
    echo "Analyzing $dataset";

    count_datatype_properties $dataset
    count_object_properties $dataset

    # count_object_property=$dataset.object_property.count.txt
    # echo > $count_object_property
    # for prop in $(cat $ontology_object_properties);do
        # echo -ne "\r -> Counting Object properties [$prop]                 "
        # echo "$prop  $(grep "$prop" $dataset |wc -l)" >> $count_object_property
    # done

    # count_class=$dataset.class.count.txt
    # echo > $count_class
    # for prop in $(cat $ontology_classes);do
        # echo -ne "\r -> Counting Classes [$prop]                 "
        # echo "$prop  $(grep "$prop" $dataset |wc -l)" >> $count_class
    # done

    # TODO extract/sort S
    # TODO extract/sort O
    # TODO extract/sort PO

    echo ""
    # Object properties
    # Classes
    # done
done
