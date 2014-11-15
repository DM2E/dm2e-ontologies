WIKI_LIST_FILE="edm-properties-wiki.lst"
OWL_LIST_FILE="edm-properties-owl.lst"

in_owl() {
    owl_qname=$(echo $1|sed 's/:/;/')
    echo "<rdf:Description rdf:about=\"&$owl_qname\">
    <rdfs:subPropertyOf rdf:resource=\"&$owl_qname\"/>
</rdf:Description>"
}


for prop_wiki in $(cat $WIKI_LIST_FILE);do
    prop_wiki=$(echo $prop_wiki)
    grep "$prop_wiki" "$OWL_LIST_FILE" >/dev/null
    if [[ $? -gt 0 ]];then
        in_owl "$prop_wiki"
    fi
done

