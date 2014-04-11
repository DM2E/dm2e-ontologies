out_dir=out
mkdir -p $out_dir
analyses_dir=/data/analyses/analysis_2014-04-08_13
datasets=(bbawdta geigeidigital mpiwgharriot mpiwgrara mpiwgrarafulltextsample onbabo onbcodices uberdingler ubffmsammlungen uibwab)
nr_datasets=${#datasets[@]}
tpl_bar_chart=tpl/bar-chart.html
tpl_pie_chart=tpl/pie-chart.html

bar_number_of_results() {
    local analysis=$1
    local title=$2
    local label=$3

    local tmpfile=$(mktemp)
    local TABLE_COLUMNS
    local TABLE_ROWS
    local out
    local i=1

    TABLE_COLUMNS="["
    TABLE_COLUMNS="$TABLE_COLUMNS['string','dataset'],"
    TABLE_COLUMNS="$TABLE_COLUMNS['number','$label']"
    TABLE_COLUMNS="$TABLE_COLUMNS]"

    TABLE_ROWS="["
    for dataset in ${datasets[@]};do
        TABLE_ROWS="$TABLE_ROWS['$dataset',"
        TABLE_ROWS="$TABLE_ROWS$(cat $analyses_dir/$dataset-count-$analysis.rq.tsv|sed '1d'|wc -l)"
        TABLE_ROWS="$TABLE_ROWS]"
        if [[ i -lt $nr_datasets ]];then
            TABLE_ROWS="$TABLE_ROWS,"
        fi
        i=$((i+1))
    done
    TABLE_ROWS="$TABLE_ROWS]"
    cp $tpl_bar_chart $tmpfile
    sed -i "s@\\$\\$\\\$TABLE_COLUMNS\\$\\$\\\$@$TABLE_COLUMNS@" $tmpfile
    sed -i "s@\\$\\$\\\$TABLE_ROWS\\$\\$\\\$@$TABLE_ROWS@" $tmpfile
    sed -i "s@\\$\\$\\\$TITLE\\$\\$\\\$@$title@" $tmpfile
    cp $tmpfile $out_dir/barno_$analysis.html
}

bar_number_of_results predicates-per-dataset "Different predicates per Dataset" "No of predicates"
bar_number_of_results hostnames "Different Hostnames per Dataset" "No of hostnames"
bar_number_of_results predicate-object-equal-statements "Statement redundancy" "No of S-O-equal stmts"
