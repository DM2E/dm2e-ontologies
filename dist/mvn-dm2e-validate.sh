#!/bin/bash
mvn -q exec:java -Dexec.mainClass=eu.dm2e.utils.Dm2eValidationCLI -Dexec.args="$*"
