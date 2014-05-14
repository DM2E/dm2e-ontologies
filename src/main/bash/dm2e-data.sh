#!/bin/bash

HOME_PROFILE="$HOME/dm2e-data.profile.sh"
LOCAL_PROFILE="./dm2e-data.profile.sh"

#---------
# CONFIG
# can be overriden with $HOME/dm2e-data.profile.sh or ./dm2e-data.profile.sh
#---------
SPARQL_DIR=$(realpath "../resources/sparql-queries")
PREFIXES="$SPARQL_DIR/prefixes.rq"
SPARQL_SCRIPT="$SPARQL_DIR/sparql-query.sh"
DM2E_EDM_JAR=$(realpath "../../../target/dm2e-edm-jar-with-dependencies.jar")
DEFAULT_IN_DIR="./dm2e-dump"
DEFAULT_OUT_DIR="./dm2e-edm"

if [[ -e  $HOME_PROFILE ]];then
    source $HOME_PROFILE
fi
if [[ -e  $LOCAL_PROFILE ]];then
    source $LOCAL_PROFILE
fi

#------------
# PARAMETERS
#-----------
FORCE=""
DATASET=""
IN_FORMAT="RDF/XML"
IN_DIR="$DEFAULT_IN_DIR"
OUT_DIR="$DEFAULT_OUT_DIR"

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
        echo "Must set dataset '--dataset'/'--ds'"
        exit 1
    fi
}

ensure_AGGREGATIONS_LIST() {
    ensure_DATASET
    if [[ -z "$AGGREGATIONS_LIST" ]];then
        AGGREGATIONS_LIST="$(clean_uri $DATASET)-aggregations.lst"
        touch $AGGREGATIONS_LIST
    fi

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

execute_sparql() {
    local query=$1
    shift
    bash "$SPARQL_SCRIPT" "$SPARQL_DIR/${query}.rq" --prefixes "$PREFIXES" $@
}

action_list_datasets() {
    execute_sparql "SELECT-list-latest-versioned-datasets"
}

action_list_aggregations() {
    ensure_DATASET
    ensure_AGGREGATIONS_LIST
    if [[ -s $AGGREGATIONS_LIST && -z "$FORCE" ]];then
        echo "$AGGREGATIONS_LIST exists and is not empty. Delete and run again to recreate or use --force"
        exit 1
    fi
    result=$(execute_sparql "SELECT-list-aggregations-in-dataset" --bind "g" "<$DATASET>" |sed '1d')
    for i in $result;do
        echo "$(strip_brackets $i)" >> $AGGREGATIONS_LIST
    done
    echo "List of aggregations written to $AGGREGATIONS_LIST"
}

action_dump_aggregations() {
    ensure_DATASET
    ensure_AGGREGATIONS_LIST
    ensure_IN_DIR
    if [[ ! -s $AGGREGATIONS_LIST ]];then
        echo "$AGGREGATIONS_LIST exists but is empty."
        exit 1
    fi
    for i in $(cat $AGGREGATIONS_LIST);do
        out_filename="$IN_DIR/$(clean_uri $i).xml"
        execute_sparql "CONSTRUCT-transitivie-closure" --bind 'agg' "<$i>" --bind 'g' "<$DATASET>" --format "xml" > $out_filename
        echo "Written $i to $out_filename"
    done
}

action_convert_to_edm() {
    ensure_IN_DIR
    ensure_OUT_DIR
    echo "Converting data in $IN_DIR to EDM -> $OUT_DIR"
    java -jar $DM2E_EDM_JAR --input_format "RDF/XML" --input_dir $IN_DIR --output_dir $OUT_DIR
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
            shift;
            DATASET=$1
            shift
            ;;
        "--aggregations-list")
            shift
            AGGREGATIONS_LIST=$1
            shift
            ;;
        "--inFormat")
            shift
            IN_FORMAT=$1
            shift
            ;;
        "--force")
            FORCE="true"
            shift
            ;;
        *)
            echo "Unknown option '$1'!"
            exit 1
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
        action_dump_aggregations
        ;;
    "convert-to-edm")
        action_convert_to_edm
        ;;
    "test")
        clean_uri 'http://data.dm2e.eu/data/dataset/uib/wab/20140311101616905'
        ;;
    *)
        echo "Unknown action '$1'!"
        exit 1
        ;;
esac
