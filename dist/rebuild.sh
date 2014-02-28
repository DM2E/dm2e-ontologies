#!/bin/bash

"Pull from git"
git pull

echo "set build date"
date=$(date)
sed -i "s/Build Date: '[^']*'/Build Date: $date/" ./src/main/java/eu/dm2e/utils/Dm2eValidationCLI.java

echo "create jar"
mvn compile assembly:single
