#!/bin/bash

usage() {
    echo "$0 [--dir DIR] [--query QUERY_FILE] [--ds DATASET]"
    echo ""
    echo "Options:"
    echo "  --dir DIR             Directory to write results to"
    echo "  --query QUERY_FILE    Single query file to use, if unspecified: all of them"
    echo "  --ds DATASET          Dataset to run queries on, if unspecified: all of them"
    exit
}

query_files=(sparql/count-triples-per-dataset.rq
sparql/count-subjects-per-dataset.rq
sparql/count-predicates-per-dataset.rq
sparql/count-objects-per-dataset.rq
sparql/count-predicate-object-equal-statements.rq
sparql/count-ranges-per-property.rq
sparql/count-literal-statements.rq
sparql/count-untyped.rq
sparql/count-types.rq
sparql/count-hostnames.rq
sparql/count-statements-per-resource-and-type.rq
sparql/count-license.rq)

datasets=(http://data.dm2e.eu/data/dataset/uber/dingler/20140410122428139
http://data.dm2e.eu/data/dataset/mpiwg/harriot/20140408150928033
http://data.dm2e.eu/data/dataset/uib/wab/20140311101616905
http://data.dm2e.eu/data/dataset/gei/gei-digital/20140301021526607
http://data.dm2e.eu/data/dataset/mpiwg/rara/20140408163521482
http://data.dm2e.eu/data/dataset/onb/abo/20140306154239247
http://data.dm2e.eu/data/dataset/bbaw/dta/20140310171954361
http://data.dm2e.eu/data/dataset/onb/codices/20140304184952678
http://data.dm2e.eu/data/dataset/ub-ffm/sammlungen/20140301004538912)

analysis_dir="/data/analyses/analysis_$(date '+%Y-%m-%d_%H')"
mkdir -p $analysis_dir


while [[ "x$1" != "x" ]];do
    case $1 in
        "--help")
            usage
            ;;
        "--dir")
            shift
            analysis_dir=$1
            shift
            ;;
        "--query")
            shift
            query_files=($1)
            shift
            ;;
        "--ds")
            shift
            datasets=($1)
            shift
            ;;
        *)
            shift
            ;;
    esac
done


total=$(( ${#datasets[@]} * ${#query_files[@]} ))
cur=1
for dataset_uri in ${datasets[@]};do
    dataset_clean=$(echo $dataset_uri|sed 's/[^a-z]//g' | sed 's/httpdatadmeeudatadataset//')
    for query in ${query_files[@]};do 
        outname="$analysis_dir/$dataset_clean-$(basename $query).tsv"
        echo "[$cur / $total] $dataset_clean -> $query -> $outname"
        # echo ./sparql-query.sh $query --bind g "<$dataset_uri>" \> "$analysis_dir/$dataset_clean.$query.tsv"
        ./sparql-query.sh $query --prefixes sparql/prefixes.rq --bind "g" "<$dataset_uri>" > $outname
        cur=$(( $cur + 1 ))
    done
done
