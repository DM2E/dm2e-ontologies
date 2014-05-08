#!/bin/bash
endpointSelect="http://localhost:9997/dm2e-direct/sparql"
prefixFile="prefixes.rq"
outputFormat="tsv"
declare -A initialBindings

echoerr() { echo $@ 1>&2; }

showUsage() {
echo "sparql-query <queryFile> [Options]"
echo ""
echo "Arguments:"
echo ""
echo "  <queryFile>                 File containing the SPARQL query, REQUIRED"
echo ""
echo "Options:"
echo ""
echo "  --endpoint <endpoint>       SPARQL endpoint to query [Default: '$endpointSelect']"
echo "  --prefixes <prefixfile>     Load SPARQL Prefixes from prefixfile [Default: '$prefixFile']"
echo "  --format <tsv|xml|json|ntriples>     Format for displaying the result bindings [Default: '$outputFormat']"
echo "  --bind <var> <val>          Replace all occurences of ?val by the value"
echo "                              (to parameterize the query) REPEATABLE"
}

urlencode() {
    echo "$1" | curl -Gso /dev/null -w %{url_effective} --data-urlencode @- "" | cut -c 3-
}

parseOpts() {
    if [[ -z $1 ]];then
        showUsage
        exit 2
    fi
    queryFile=$1
    shift;
    while [[ ! -z $1 ]];do
        case $1 in
            "--endpoint")
                endpointSelect=$2;
                shift ; shift
                ;;
            "--prefixes")
                prefixFiles=$2;
                shift ; shift
                ;;
            "--format")
                outputFormat=$2;
                shift ; shift
                ;;
            "--bind")
                local varName=$2
                local varVal=$3
                initialBindings["$varName"]=$varVal
                shift ; shift ; shift
                ;;
            *)
                showUsage
                exit 1
                ;;
        esac
    done
}

# Parse command line options
parseOpts $*

# create unformatted query by concatenating prefixes and query file sans comments
queryUnformatted=$(cat $prefixFile $queryFile | grep -v '^\s*#')

# Initialize with initial bindings
for bindingName in ${!initialBindings[@]};do
    bindingValue=${initialBindings["$bindingName"]}
    echoerr "Binding $bindingName to $bindingValue"
    echo "Binding $bindingName to $bindingValue"
    queryUnformatted=$(echo "$queryUnformatted" | sed "s,\?$bindingName\b,$bindingValue,")
done

echoerr $queryUnformatted

# URL Encode
queryFormatted=$(urlencode "$queryUnformatted")

# Send request
case $outputFormat in
    "tsv")
        ;&
    "json")
        ;&
    "xml")
        url="${endpointSelect}?format=${outputFormat}&query=${queryFormatted}"
        # echo $url
        curl $url
        ;;
    "ntriples")
        url="${endpointSelect}?query=${queryFormatted}"
        curl -H "Accept: application/n-triples" $url
        ;;
    *)
        echo "Unhandled format '$outputFormat'"
esac
