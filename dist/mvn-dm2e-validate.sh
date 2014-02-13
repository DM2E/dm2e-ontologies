#!/bin/bash
mvn -o -q exec:java -Dexec.mainClass=eu.dm2e.utils.Dm2eValidationCLI -Dexec.args="$*"
