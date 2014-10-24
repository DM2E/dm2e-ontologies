#!/bin/bash
# vim: set foldmethod=marker foldmarker={,}:

SCRIPT_DIR=$(dirname $(readlink -f $0))
echo $SCRIPT_DIR

#{ CONFIG
# can be overriden with $HOME/dm2e-data.profile.sh or ./dm2e-data.profile.sh
# See commented default dm2e-data.profile.sh
HOME_PROFILE="$HOME/dm2e-data.profile.sh"
LOCAL_PROFILE="$PWD/dm2e-data.profile.sh"
DEFAULT_BASE_DIR="./dm2e2edm"
DEFAULT_IN_DIR="dm2e-rdf"
DEFAULT_OUT_DIR="edm-rdf"
DEFAULT_CLEAN_DIR="edm-rdf-clean"
DEFAULT_EDM_VALIDATION_DIR="edm-validation"
DEFAULT_DM2E_VALIDATION_DIR="dm2e-validation"
DEFAULT_DATASET_LIST="dataset.lst"

export DATASET
export AGGREGATIONS_LIST
export SPARQL_DIR=$(realpath "$SCRIPT_DIR/../resources/sparql-queries")
export DM2E_EDM_JAR=$(realpath "$SCRIPT_DIR/../../../target/dm2e-edm-jar-with-dependencies.jar")
export EDM_VALIDATION_JAR=$(realpath "$SCRIPT_DIR/../../../../edm-validation/target/edm-validation-jar-with-dependencies.jar")

# TODO
export NUMBER_OF_JOBS=4
# TODO
export PARALLELIZE="true"

if [[ -e  $HOME_PROFILE ]];then
    source $HOME_PROFILE
fi
if [[ -e  $LOCAL_PROFILE ]];then
    source $LOCAL_PROFILE
fi
#}

#{ PARAMETERS
export BASE_DIR="${BASE_DIR:-$DEFAULT_BASE_DIR}"
export IN_DIR="${IN_DIR:-$BASE_DIR/$DEFAULT_IN_DIR}"
export OUT_DIR="${OUT_DIR:-$BASE_DIR/$DEFAULT_OUT_DIR}"
export CLEAN_DIR="${CLEAN_DIR:-$BASE_DIR/$DEFAULT_CLEAN_DIR}"
export EDM_VALIDATION_DIR="${EDM_VALIDATION_DIR:-$BASE_DIR/$DEFAULT_EDM_VALIDATION_DIR}"
export DATASET_LIST="${DATASET_LIST:-$BASE_DIR/$DEFAULT_DATASET_LIST}"
export PREFIXES="$SPARQL_DIR/prefixes.rq"
export SPARQL_SCRIPT="$SPARQL_DIR/sparql-query.sh"
export XSLT_SORT="$SPARQL_DIR/sort.xsl"
export DATASET=""
export IN_FORMAT="RDF/XML"
export PURGE=""
#}

#{ HELPER FUNCTIONS

# Show script invocation
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
        debug               Dump the current environment and exit
        list-datasets       List the latest versions of all datasets
            --dataset-list              File to write the dataset URIs to [OPTIONAL, Default: '$DEFAULT_BASE_DIR/$DEFAULT_DATASET_LIST']
        list-aggregations   List the latest versions of all datasets
            --dataset/ds <URI>          URI of the dataset [REQUIRED]
        dump-aggregations   Dump the transitive closure of the list of aggregations to \$IN_DIR
            --dataset/ds <URI>          URI of the dataset [REQUIRED]
        convert-to-edm      Convert the data in \$IN_DIR to EDM RDF/XML in \$OUT_DIR
        cleanup-edm         Transform the EDM RDF/XML in \$OUT_DIR to prettier RDF/XML in \$CLEAN_DIR
        batch-dump          Combines 'list-datasets', 'list-aggregations' and 'dump-aggregations'
            --dataset-list              File to write/read the dataset URIs to/from [OPTIONAL, Default: '$DEFAULT_BASE_DIR/$DEFAULT_DATASET_LIST']
        batch-convert       Combines 'convert-to-edm' and 'cleanup-edm'
        validate-edm        Validate the EDM RDF/XML in \$CLEAN_DIR
"
    exit 1
}

# Strip a URI down to an ID for the aggregation
# http://data.dm2e.eu/data/aggregation/mpiwg/harriot/MPIWG_MV67WEK4 -> mpiwgharriotMPIWG_MV67WEK4
aggregation_id_from_uri() {
    local str=$1
    str=$(echo "$str"|sed 's/[^A-Za-z0-9_-]//g')
    str=$(echo "$str"|sed 's@httpdatadm2eeudata@@')
    str=$(echo "$str"|sed 's@^dataset@@')
    str=$(echo "$str"|sed 's@^aggregation@@')
    echo $str
}

# Strip a URI down to an ID for the dataset
# http://data.dm2e.eu/data/aggregation/mpiwg/harriot/MPIWG_MV67WEK4 -> mpiwgharriot
# http://data.dm2e.eu/data/dataset/mpiwg/harriot/20140716113714616 -> mpiwgharriot
dataset_id_from_uri() {
    local str=$1
    str=$(echo "$str"|sed 's|^.*aggregation/||')
    str=$(echo "$str"|sed 's|^.*dataset/||')
    str=$(echo "$str"|sed 's|/||')
    str=$(echo "$str"|sed 's|/.*$||')
    echo $str
}

# Execute a SPARQL query
execute_sparql() {
    local query=$1
    shift
    bash "$SPARQL_SCRIPT" "$SPARQL_DIR/${query}.rq" --prefixes "$PREFIXES" $@
}

## remove '<' and '>' from script
strip_brackets() {
    local str=$1
    str=$(echo "$str"|sed 's/[<>]//g')
    echo $str
}

# Dump current variable settings
debug() {
    echo "/**** DEBUG ****"
    echo ".  PWD='$PWD'"
    echo ".  BASE_DIR='$BASE_DIR'"
    echo ".    IN_DIR='$IN_DIR'"
    echo ".    OUT_DIR='$OUT_DIR'"
    echo ".    CLEAN_DIR='$CLEAN_DIR'"
    echo ".    DATASET_LIST='$DATASET_LIST'"
    echo ".  DATASET='$DATASET'"
    echo ".  AGGREGATIONS_LIST='$AGGREGATIONS_LIST'"
    echo "\**** DEBUG ****"
}

purge_if_necessary() {
    dir=$1
    if [[ -e $dir && ! -z $(ls $dir) && ! -z "$PURGE" ]];then
        if [[ -d $1 ]];then
            echo "Are you sure you want to delete all files in '$dir' <yes/no>?"
            read yesno
            if [[ "$yesno" == "yes" ]];then
                rm -ri $dir/*
            fi
        fi
    fi
}

#}

#{ ENSURE VARIABLES ARE SET
# Make sure $DATASET is set
ensure_DATASET() {
    if [[ -z "$DATASET" ]];then
        usage "Must set dataset '--dataset'/'--ds'"
    fi
}

# Make sure $AGGREGATIONS_LIST is set
ensure_AGGREGATIONS_LIST() {
    ensure_DATASET
    AGGREGATIONS_LIST="$BASE_DIR/$(aggregation_id_from_uri $DATASET)-aggregations.lst"
    touch $AGGREGATIONS_LIST
}

# Make sure $IN_DIR is set
ensure_IN_DIR() {
    if [[ ! -e "$IN_DIR" ]];then
        mkdir -p "$IN_DIR"
    fi
    if [[ ! -z "$DATASET" ]];then
        local dataset_name=$(dataset_id_from_uri "$DATASET")
        mkdir -p "$IN_DIR/$dataset_name"
    fi
}

# Make sure $OUT_DIR is set
ensure_OUT_DIR() {
    if [[ ! -e "$OUT_DIR" ]];then
        mkdir -p "$OUT_DIR"
    fi
    if [[ ! -z "$DATASET" ]];then
        local dataset_name=$(dataset_id_from_uri "$DATASET")
        mkdir -p "$OUT_DIR/$dataset_name"
    fi
}

# Make sure $CLEAN_DIR is set
ensure_CLEAN_DIR() {
    ensure_OUT_DIR
    if [[ ! -e "$CLEAN_DIR" ]];then
        mkdir -p "$CLEAN_DIR"
    fi
    if [[ ! -z "$DATASET" ]];then
        local dataset_name=$(dataset_id_from_uri "$DATASET")
        mkdir -p "$CLEAN_DIR/$dataset_name"
    fi
}

# Make sure $EDM_VALIDATION_DIR is set
ensure_EDM_VALIDATION_DIR() {
    ensure_OUT_DIR
    if [[ ! -e "$EDM_VALIDATION_DIR" ]];then
        mkdir -p "$EDM_VALIDATION_DIR"
    fi
    if [[ ! -z "$DATASET" ]];then
        local dataset_name=$(dataset_id_from_uri "$DATASET")
        mkdir -p "$EDM_VALIDATION_DIR/$dataset_name"
    fi
}

#}

#{ ACTIONS
# Generate a list of datasets by SPARQLing for the latest versioned datasets
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

# Generate a a list of aggregations within a dataset
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

# Dump the aggregations in the list as RDF/XML
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
    # if [[ "$PARALLELIZE" == "true" ]];then
    cat $AGGREGATIONS_LIST | \
        SHELL=/bin/bash \
        parallel --gnu  --progress --eta --jobs +30 \
            execute_sparql "CONSTRUCT-transitivie-closure" "--bind" "agg" "'\\<{}\\>'" "--bind" "g" "'\\<$DATASET\\>'" --format "xml" \
            "2>/dev/null" \
            ">" "$IN_DIR/\$(dataset_id_from_uri '{}')/\$(aggregation_id_from_uri '{}').xml"
}

# Convert the DM2E RDF/XML to EDM RDF/XML
action_convert_to_edm() {
    ensure_IN_DIR
    ensure_OUT_DIR
    echo "** START CONVERT **"
    echo "Converting data in $IN_DIR to EDM -> $OUT_DIR"
    for fulldir in $(find $IN_DIR -mindepth 1 -type d);do
        dir=$(basename $fulldir)
        mkdir -p $OUT_DIR/$dir
        find $IN_DIR/$dir -type f | \
            SHELL=/bin/bash \
                parallel --gnu  --progress --eta -n 150 \
                java -jar "$DM2E_EDM_JAR" "--input_format" "RDF/XML" "--output_dir" "$OUT_DIR/$dir" "--input_file" "{}"
            # java -jar "$DM2E_EDM_JAR" "--input_format" "RDF/XML" "--output_dir" "$OUT_DIR" "--input_dir" "$IN_DIR"
        echo "DONE with '$dir'"
    done
    echo "** COMPLETED CONVERT **"
}

_paralelized_cleanup_edm() {
    i=$1
    out_filename=$2
    # out_filename="$CLEAN_DIR/$(basename $i)"

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

# Transform the EDM RDF/XML to syntactically tasty RDF/XML for Europeana ingestion
action_cleanup_edm() {
    ensure_CLEAN_DIR

    echo "** START CLEANUP **"
    for fulldir in $(find $OUT_DIR -mindepth 1 -type d);do
        dir=$(basename $fulldir)
        mkdir -p $CLEAN_DIR/$dir
        find $OUT_DIR/$dir -type f | \
            SHELL=/bin/bash \
                parallel --gnu --progress --eta \
                _paralelized_cleanup_edm "{}" "$CLEAN_DIR/$dir/\$(basename '{}')"
    done
    echo "** COMPLETED CLEANUP **"
}

_parallelized_dump() {
    DATASET=$1
    ensure_AGGREGATIONS_LIST
    action_list_aggregations
    action_dump_aggregations
}

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
        # SHELL=/bin/bash parallel --gnu --progress --eta --ungroup --jobs $NUMBER_OF_JOBS _parallelized_dump ::: "${arr[@]}"
        for i in ${arr[@]};do
            _parallelized_dump $i
        done
    fi
}

action_batch_convert() {
    action_convert_to_edm
    action_cleanup_edm
    action_validate_edm
}

# Create validation reports for all not-EDM-XSD valid clean RDF/XML
action_validate_edm() {
    ensure_CLEAN_DIR
    ensure_EDM_VALIDATION_DIR
    echo "** START VALIDATION **"
    echo "Validating the files in \$CLEAN_DIR [$CLEAN_DIR]"
    for fulldir in $(find $CLEAN_DIR -mindepth 1 -type d);do
        dir=$(basename $fulldir)
        echo "Validating $dir"
        mkdir -p "$EDM_VALIDATION_DIR/$dir"
        java -jar $EDM_VALIDATION_JAR $CLEAN_DIR/$dir
        find $CLEAN_DIR/$dir -type f -name '*validation.txt'| \
            parallel --gnu -m mv -t "$EDM_VALIDATION_DIR/$dir" "{}"
        nr_invalid=$(find "$EDM_VALIDATION_DIR/$dir" -type f|wc -l)
        if [[ "$nr_invalid" -gt 0 ]];then
            echo "!!! '$dir' contains >  $nr_invalid  < invalid EDM files !!!"
        fi
    done
    echo "** COMPLETED VALIDATION **"
}

#}

#{ EXPORTED FUNCTIONS
# This is important for parallel(1) to fork off functions
export -f ensure_IN_DIR
export -f ensure_OUT_DIR
export -f ensure_CLEAN_DIR
export -f ensure_DATASET
export -f ensure_AGGREGATIONS_LIST
export -f action_list_aggregations
export -f action_dump_aggregations
export -f _parallelized_dump
export -f _paralelized_cleanup_edm
export -f aggregation_id_from_uri
export -f dataset_id_from_uri
export -f execute_sparql
#}

#{ MAIN

# Parse command line args
#{
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
        "--base-dir")
            BASE_DIR=$2
            shift ; shift;
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
#}

# ENSURE BASE DIR
mkdir -p $BASE_DIR

# Execute actions
#{
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
    "validate-edm"|"edm-validate")
        action_validate_edm
        ;;
    "help")
        usage
        ;;
    "debug")
        debug
        ;;
    *)
        usage "Unknown action '$ACTION'!"
        ;;
esac
#}
#}
