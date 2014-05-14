#!/bin/bash

#---------
# CONFIG
#---------
SPARQL_DIR=$(realpath "../resources/sparql-queries")
PREFIXES="$SPARQL_DIR/prefixes.rq"
SPARQL_SCRIPT="$SPARQL_DIR/sparql-query.sh"
DM2E_EDM_JAR=$(realpath "../../../target/dm2e-edm-jar-with-dependencies.jar")
DEFAULT_IN_DIR="../../../test/dm2e-dump"
DEFAULT_OUT_DIR="../../../test/dm2e-edm"
