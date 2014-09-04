#!/bin/bash
# vim: set foldmethod=marker foldmarker={,}:


export now=$(date -u '+%Y-%m-%d__%H_%M_%S')
export IN_FOLDER
export IN_FORMAT="rdfxml"
export OUT_FILE="./ntriplified-dump.$now.zip"
export tmp="$(mktemp -d)"
export NUMBER_OF_LINES=50000
if [[ -z "$tmp" ]];then
    echo "!! Couldn't create temp dir !!"
    exit
else
    echo
    trap "cleanup" 0
fi

cleanup() {
    echo "---------------------------"
    echo "Step -1: Cleanup           "
    echo "---------------------------"
    if [[ ! -z "$tmp" ]] && [[ -d "$tmp" ]];then
        echo "Removing tempdir '$tmp'"
        rm -r "$tmp"
    fi
}

usage() {
    if [[ ! -z $1 ]];then
        echo "!! $1 !!"
    fi
    echo "ntriply-folder --in IN_FOLDER --out Output file"
    echo "Compresses RDF data into the smallest possible N-TRIPLE seriealization, then splits and compresses the result"
    echo ""
    echo "Options"
    echo "    --in/-i IN_FOLDER             Folder to read RDF data from [REQUIRED]"
    echo "    --out/-o OUT_FILE             Filename of the result [Default: '$OUT_FILE']"
    echo "    --number-of-lines/-n NUMBER   Number of lines [Default '$NUMBER_OF_LINES']"
    echo "    --in-format/-f (RDF/XML|N-TRIPLE|TURTLE)     Input format [DEFAULT: '$IN_FORMAT']"
}

dump_as_ntriples() {
    local joinedfile="$tmp/000_join_000.nt"
    local sortedfile="$tmp/000_sort_000.nt"
    local outdir="$tmp/000_out_000"
    local splitdir="$tmp/split"
    echo "Temp Dir: $tmp"
    echo "---------------------------"
    echo "Step 1: Convert to N-TRIPLE"
    echo "---------------------------"
    echo mkdir -p $outdir
    echo
    mkdir -p $outdir
    find $IN_FOLDER -maxdepth 1 -type f | \
        parallel --gnu  --progress --eta --jobs +30 \
            rapper -i "$IN_FORMAT" -o "ntriples" "{}" \
            ">" "$outdir/\$(basename '{}')" \
            "2>/dev/null"
            # sort \
    echo "---------------------------"
    echo "Step 2: Join               "
    echo "---------------------------"
    touch $joinedfile
    echo find "$outdir" -type f '|' xargs -L 100 cat '>>' "$joinedfile" "'<'"
    time find "$outdir" -type f | xargs -L 100 cat >> "$joinedfile"
    echo "---------------------------"
    echo "Step 3: Sort Uniq          "
    echo "---------------------------"
    echo sort -u "$joinedfile" '>' $sortedfile
    time sort -u "$joinedfile" > $sortedfile
    echo "---------------------------"
    echo "Step 4: Split              "
    echo "---------------------------"
    mkdir "$splitdir"
    echo split -l $NUMBER_OF_LINES -d $sortedfile -a5 "$splitdir/"
    time split -l $NUMBER_OF_LINES -d $sortedfile -a5 "$splitdir/"
    find $splitdir -type f -exec mv "{}" "{}.nt" \;
    echo "---------------------------"
    echo "Step 5: Zip it             "
    echo "---------------------------"
    echo zip -r -j --quiet "$splitdir" $OUT_FILE
    time zip -r -j --quiet "$OUT_FILE" "$splitdir"
}

# OPTIONS {
#-----------
while [[ ! -z "$1" ]];do
    case "$1" in
        "--in"|"-i")
            IN_FOLDER=$2
            shift ; shift
            ;;
        "--out"|"-o")
            OUT_FILE=$2
            shift ; shift
            ;;
        "--number-of-lines"|"-n")
            NUMBER_OF_LINES=$2
            shift ; shift
            ;;
        "--inFormat"|"-f")
            IN_FORMAT=$(echo "$2"|sed 's/[^a-zA-Z0-9]//g'| perl -ne 'print lc')
            case "$IN_FORMAT" in
                "rdfxml"|"ntriple"|"turtle") ;;
                *) usage "Unknown input format $2"
                    ;;
            esac
            shift ; shift
            ;;
        "-h") ;&
        "--h") ;&
        "-help") ;&
        "--help")
            usage
            exit
            ;;
        *)
            usage "Unknown option '$1'!"
            exit 1
            ;;
    esac
done
#}

# MAIN {
#-----------
if [[ -z "$IN_FOLDER" ]];then
    usage "Must specify input folder ('--in'|'-i')"
    exit 1
fi
dump_as_ntriples 
#}
