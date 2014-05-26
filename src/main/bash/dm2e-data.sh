#!/bin/bash

usage() {
    if [[ ! -z "$1" ]];then
        echo $1
    fi
    echo "Usage (see README for full docs)
    
    bash $0 <action> [options]

    Global options:
        --purge             Empty directories and list files before writing to them
        --in-dir            Set \$IN_DIR
        --out-dir           Set \$IN_DIR
        --clean-dir         Set \$CLEAN_DIR

    Actions / options:
        list-datasets       List the latest versions of all datasets
            --dataset-list              File to write the dataset URIs to [OPTIONAL]
        list-aggregations   List the latest versions of all datasets
            --dataset/ds <URI>          URI of the dataset [REQUIRED]
        dump-aggregations   Dump the transitive closure of the list of aggregations to \$IN_DIR
            --dataset/ds <URI>          URI of the dataset [REQUIRED]
        convert-to-edm      Convert the data in \$IN_DIR to EDM RDF/XML in \$OUT_DIR
        cleanup-edm         Transform the EDM RDF/XML in \$OUT_DIR to prettier RDF/XML in \$CLEAN_DIR
        batch-dump          Combines 'list-datasets', 'list-aggregations' and 'dump-aggregations'
        batch-convert       Combines 'convert-to-edm' and 'cleanup-edm'
"
    exit 1
}

HOME_PROFILE="$HOME/dm2e-data.profile.sh"
LOCAL_PROFILE="./dm2e-data.profile.sh"
DEFAULT_IN_DIR="./dm2e-dump"
DEFAULT_OUT_DIR="./dm2e-edm"
DEFAULT_CLEAN_DIR="./dm2e-edm-clean"
DEFAULT_DATASET_LIST="./dataset.lst"

#---------
# CONFIG
# can be overriden with $HOME/dm2e-data.profile.sh or ./dm2e-data.profile.sh
#---------
SPARQL_DIR=$(realpath "../resources/sparql-queries")
DM2E_EDM_JAR=$(realpath "../../../target/dm2e-edm-jar-with-dependencies.jar")
IN_DIR="$DEFAULT_IN_DIR"
OUT_DIR="$DEFAULT_OUT_DIR"
CLEAN_DIR="$DEFAULT_CLEAN_DIR"
DATASET_LIST="$DEFAULT_DATASET_LIST"

if [[ -e  $HOME_PROFILE ]];then
    source $HOME_PROFILE
fi
if [[ -e  $LOCAL_PROFILE ]];then
    source $LOCAL_PROFILE
fi

#------------
# PARAMETERS
#-----------
PREFIXES="$SPARQL_DIR/prefixes.rq"
SPARQL_SCRIPT="$SPARQL_DIR/sparql-query.sh"
XSLT_SORT="$SPARQL_DIR/sort.xsl"
DATASET=""
IN_FORMAT="RDF/XML"
PURGE=""

clean_uri() {
    local str=$1
    str=$(echo "$str"|sed 's/[^A-Za-z0-9_-]//g')
    str=$(echo "$str"|sed 's@httpdatadm2eeudata@@')
    str=$(echo "$str"|sed 's@^dataset@@')
    str=$(echo "$str"|sed 's@^aggregation@@')
    echo $str
}

strip_brackets() {
    local str=$1
    str=$(echo "$str"|sed 's/[<>]//g')
    echo $str
}

ensure_DATASET() {
    if [[ -z "$DATASET" ]];then
        usage "Must set dataset '--dataset'/'--ds'"
    fi
}

ensure_AGGREGATIONS_LIST() {
    ensure_DATASET
    AGGREGATIONS_LIST="$(clean_uri $DATASET)-aggregations.lst"
    touch $AGGREGATIONS_LIST
}

ensure_IN_DIR() {
    if [[ ! -e "$IN_DIR" ]];then
        mkdir -p "$IN_DIR"
    fi
}

ensure_OUT_DIR() {
    if [[ ! -e "$OUT_DIR" ]];then
        mkdir -p "$OUT_DIR"
    fi
}

ensure_CLEAN_DIR() {
    ensure_OUT_DIR
    if [[ ! -e "$CLEAN_DIR" ]];then
        mkdir -p "$CLEAN_DIR"
    fi
}

execute_sparql() {
    local query=$1
    shift
    bash "$SPARQL_SCRIPT" "$SPARQL_DIR/${query}.rq" --prefixes "$PREFIXES" $@
}

action_list_datasets() {
    result=$(execute_sparql "SELECT-list-latest-versioned-datasets" 2>/dev/null|sed '1d')
    echo "" > $DATASET_LIST
    for i in $result;do
        i=$(strip_brackets $i)
        echo $i
        echo $i >> $DATASET_LIST
    done
    echo "Written list of datasets to '$DATASET_LIST'"
}

action_list_aggregations() {
    ensure_DATASET
    ensure_AGGREGATIONS_LIST
    # if [[ -s $AGGREGATIONS_LIST && -z "$PURGE" ]];then
    #     usage "$AGGREGATIONS_LIST exists and is not empty. Delete and run again to recreate or use --purge"
    # fi
    echo "" > $AGGREGATIONS_LIST
    echo "Getting all aggregations in <$DATASET>"
    execute_sparql "SELECT-list-aggregations-in-dataset" --bind "g" "<$DATASET>" 2>/dev/null|sed '1d' > $AGGREGATIONS_LIST
    echo "Got them. Cleanup."
    sed -i 's/^<//' $AGGREGATIONS_LIST
    sed -i 's/>$//' $AGGREGATIONS_LIST
    echo "List of aggregations written to $AGGREGATIONS_LIST"
    echo "$(wc -l $AGGREGATIONS_LIST|cut -d' ' -f1) Aggregations found"
}

action_dump_aggregations() {
    ensure_DATASET
    ensure_AGGREGATIONS_LIST
    ensure_IN_DIR
    if [[ ! -s $AGGREGATIONS_LIST ]];then
        usage "$AGGREGATIONS_LIST exists but is empty."
    fi
    local total=$(wc -l "$AGGREGATIONS_LIST"|cut -d' ' -f1 )
    local cur=0
    for i in $(cat $AGGREGATIONS_LIST);do
        out_filename="$IN_DIR/$(clean_uri $i).xml"
        execute_sparql "CONSTRUCT-transitivie-closure" --bind 'agg' "<$i>" --bind 'g' "<$DATASET>" --format "xml" 2>/dev/null > $out_filename
        cur=$(( $cur + 1 ))
        echo -ne "[$cur / $total] Dumped <$i> to $out_filename\r"
    done
    echo
}

action_convert_to_edm() {
    ensure_IN_DIR
    ensure_OUT_DIR
    echo "Converting data in $IN_DIR to EDM -> $OUT_DIR"
    java -jar $DM2E_EDM_JAR --input_format "RDF/XML" --input_dir $IN_DIR --output_dir $OUT_DIR 2>/dev/null
}

action_cleanup_edm() {
    ensure_CLEAN_DIR

    cur=0
    total=$(ls $OUT_DIR/*.xml|wc -l|cut -d' ' -f1)
    for i in $OUT_DIR/*.xml;do

        out_filename="$CLEAN_DIR/$(basename $i)"

        cur=$(( $cur + 1 ))
        echo -ne "[$cur / $total] Cleaning up $i -> $out_filename\r"

        # create tempfiles
        tmpfile=$(mktemp)

        # produce the right kind of RDF/XML-ABBREV for Europeana's ingestion needs
        rapper -q -i rdfxml -o rdfxml-abbrev $i > $tmpfile

        # sort the thing with a simple XSLT script
        xsltproc $XSLT_SORT $tmpfile > $out_filename

        # remove temp files
        rm $tmpfile
    done
    echo
}

action_batch_dump() {
    if [[ ! -z "$DATASET" ]];then
        ensure_AGGREGATIONS_LIST
        action_list_aggregations
        action_dump_aggregations
    else
        action_list_datasets
        for ds in $(cat $DATASET_LIST);do
            DATASET=$ds
            ensure_AGGREGATIONS_LIST
            action_list_aggregations
            action_dump_aggregations
        done
    fi
}
action_batch_convert() {
    action_convert_to_edm
    action_cleanup_edm
}

purge_if_necessary() {
    dir=$1
    if [[ -e $dir && ! -z $(ls $dir) && ! -z "$PURGE" ]];then
        if [[ -d $1 ]];then
            echo "Are you sure you want to delete all files in '$dir' <yes/no>?"
            read yesno
            if [[ "$yesno" == "yes" ]];then
                rm -v $dir/*
            fi
        fi
    fi
}

ACTION=$1
shift

#-----------
# OPTIONS
#-----------
while [[ ! -z "$1" ]];do
    case "$1" in
        "--ds") ;&
        "--dataset")
            DATASET=$2
            shift ; shift
            ;;
        "--dataset-list")
            DATASET_LIST=$2
            shift ; shift
            ;;
        "--inFormat")
            IN_FORMAT=$2
            shift ; shift
            ;;
        "--in-dir")
            IN_DIR=$2
            shift ; shift;
            ;;
        "--out-dir")
            OUT_DIR=$2
            shift ; shift;
            ;;
        "--clean-dir")
            CLEAN_DIR=$2
            shift ; shift;
            ;;
        "--purge")
            PURGE="true"
            shift
            ;;
        "-h") ;&
        "--h") ;&
        "-help") ;&
        "--help")
            usage
            ;;
        *)
            usage "Unknown option '$1'!"
            ;;
    esac
done

#-----------
# ACTIONS
#-----------
case "$ACTION" in
    "list-datasets")
        action_list_datasets
        ;;
    "list-aggregations")
        action_list_aggregations
        ;;
    "dump-aggregations")
        purge_if_necessary $IN_DIR
        action_dump_aggregations
        ;;
    "convert-to-edm")
        purge_if_necessary $OUT_DIR
        action_convert_to_edm
        ;;
    "cleanup-edm")
        purge_if_necessary $CLEAN_DIR
        action_cleanup_edm
        ;;
    "batch-dump")
        purge_if_necessary $IN_DIR
        action_batch_dump
        ;;
    "batch-convert")
        purge_if_necessary $OUT_DIR
        purge_if_necessary $CLEAN_DIR
        action_batch_convert
        ;;
    "help")
        usage
        ;;
    *)
        usage "Unknown action '$ACTION'!"
        ;;
esac
