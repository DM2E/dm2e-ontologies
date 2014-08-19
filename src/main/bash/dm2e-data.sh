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
            --dataset-list              File to write the dataset URIs to [OPTIONAL, Default: '$DEFAULT_DATASET_LIST']
        list-aggregations   List the latest versions of all datasets
            --dataset/ds <URI>          URI of the dataset [REQUIRED]
        dump-aggregations   Dump the transitive closure of the list of aggregations to \$IN_DIR
            --dataset/ds <URI>          URI of the dataset [REQUIRED]
        convert-to-edm      Convert the data in \$IN_DIR to EDM RDF/XML in \$OUT_DIR
        cleanup-edm         Transform the EDM RDF/XML in \$OUT_DIR to prettier RDF/XML in \$CLEAN_DIR
        batch-dump          Combines 'list-datasets', 'list-aggregations' and 'dump-aggregations'
            --dataset-list              File to write/read the dataset URIs to/from [OPTIONAL, Default: '$DEFAULT_DATASET_LIST']
        batch-convert       Combines 'convert-to-edm' and 'cleanup-edm'
        validate-edm        Validate the EDM RDF/XML in \$OUT_DIR to prettier RDF/XML in \$CLEAN_DIR
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
export DATASET
export AGGREGATIONS_LIST
export SPARQL_DIR=$(realpath "../resources/sparql-queries")
export DM2E_EDM_JAR=$(realpath "../../../target/dm2e-edm-jar-with-dependencies.jar")
export EDM_VALIDATION_JAR=$(realpath "../../../../edm-validation/target/edm-validation-jar-with-dependencies.jar")
export IN_DIR="$DEFAULT_IN_DIR"
export OUT_DIR="$DEFAULT_OUT_DIR"
export CLEAN_DIR="$DEFAULT_CLEAN_DIR"
export DATASET_LIST="$DEFAULT_DATASET_LIST"
export NUMBER_OF_JOBS=4

if [[ -e  $HOME_PROFILE ]];then
    source $HOME_PROFILE
fi
if [[ -e  $LOCAL_PROFILE ]];then
    source $LOCAL_PROFILE
fi

#------------
# PARAMETERS
#-----------
export PREFIXES="$SPARQL_DIR/prefixes.rq"
export SPARQL_SCRIPT="$SPARQL_DIR/sparql-query.sh"
export XSLT_SORT="$SPARQL_DIR/sort.xsl"
export DATASET=""
export IN_FORMAT="RDF/XML"
export PURGE=""

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
    echo "DATASET $DATASET"
    echo "IN_DIR $IN_DIR"
    echo "AGGREGATIONS_LIST $AGGREGATIONS_LIST"
    if [[ ! -s $AGGREGATIONS_LIST ]];then
        usage "$AGGREGATIONS_LIST exists but is empty."
    fi
    # arr=($(cat $AGGREGATIONS_LIST))
    cat $AGGREGATIONS_LIST | \
        SHELL=/bin/bash \
        parallel --gnu  --progress --eta \
            execute_sparql "CONSTRUCT-transitivie-closure" "--bind" "agg" "'\\<{}\\>'" "--bind" "g" "'\\<$DATASET\\>'" --format "xml" \
            '2>/dev/null' \
            ">" "$IN_DIR/\$(clean_uri '{}').xml"
}

action_convert_to_edm() {
    ensure_IN_DIR
    ensure_OUT_DIR
    echo "Converting data in $IN_DIR to EDM -> $OUT_DIR"
    find $IN_DIR | \
        SHELL=/bin/bash \
            parallel --gnu  --progress --eta -s 15000 -m \
            java -jar "$DM2E_EDM_JAR" "--input_format" "RDF/XML" "--output_dir" "$OUT_DIR" "--input_file" "{}" \
            "2>/dev/null" \
            "2>/dev/null"
    echo "DONE"
}

_paralelized_cleanup_edm() {
    i=$1
    out_filename="$CLEAN_DIR/$(basename $i)"

    # cur=$(( $cur + 1 ))
    # echo -ne "[$cur / $total] Cleaning up $i -> $out_filename\r"

    # create tempfiles
    tmpfile=$(mktemp)

    # produce the right kind of RDF/XML-ABBREV for Europeana's ingestion needs
    rapper -q -i rdfxml -o rdfxml-abbrev $i > $tmpfile 2>/dev/null

    # sort the thing with a simple XSLT script
    xsltproc $XSLT_SORT $tmpfile > $out_filename 2>/dev/null

    # remove temp files
    rm $tmpfile
}

action_cleanup_edm() {
    ensure_CLEAN_DIR

    find $OUT_DIR -type f | \
        SHELL=/bin/bash parallel --gnu --progress --eta --ungroup _paralelized_cleanup_edm
    echo
}

_parallelized_dump() {
    DATASET=$1
    ensure_AGGREGATIONS_LIST
    action_list_aggregations
    action_dump_aggregations
}
export -f ensure_IN_DIR
export -f ensure_OUT_DIR
export -f ensure_CLEAN_DIR
export -f ensure_DATASET
export -f ensure_AGGREGATIONS_LIST
export -f action_list_aggregations
export -f action_dump_aggregations
export -f _parallelized_dump
export -f _paralelized_cleanup_edm
export -f clean_uri
export -f execute_sparql

action_batch_dump() {
    if [[ ! -z "$DATASET" ]];then
        ensure_AGGREGATIONS_LIST
        action_list_aggregations
        action_dump_aggregations
    else
        if [[ ! -e "$DATASET_LIST"  && -z "$PURGE" ]];then
            action_list_datasets
        else
            echo "Dataset list '$DATASET_LIST' exists, skip re-generation. --purge to force it."
        fi
        arr=()
        while read ds; do
            echo $ds | grep -q '^\s*[#;]' && continue
            arr+=($ds)
        done < $DATASET_LIST
        SHELL=/bin/bash parallel --gnu --progress --eta --ungroup --jobs $NUMBER_OF_JOBS _parallelized_dump ::: "${arr[@]}"
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

action_validate_edm() {
    ensure_OUT_DIR
    echo "Validating the files in \$OUT_DIR"
    java -jar $EDM_VALIDATION_JAR $OUT_DIR
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
    "validate-edm")
        action_validate_edm
        ;;
    "help")
        usage
        ;;
    *)
        usage "Unknown action '$ACTION'!"
        ;;
esac
