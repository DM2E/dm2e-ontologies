#!/bin/bash

echo "!!!!!!!"
echo ""
echo "Rebuilding should only be done on the server"
echo ""
echo "Are you sure you are on the server and don't have any changes staged for Dm2eValidationCLI.java?"
echo ""
echo "!!!!!!!"
echo "(yes/no)"
read yesno
if [[ ! $yesno = "yes" ]];then
    exit 2;
fi
echo "proceeding"


echo "Reset CLI"
git checkout -- src/main/java/eu/dm2e/utils/Dm2eValidationCLI.java

echo "Pull from git"
git pull

echo "set build date"
date=$(date)
sed -i "s/Build Date: '[^']*'/Build Date: $date/" ./src/main/java/eu/dm2e/utils/Dm2eValidationCLI.java

echo "Install"
mvn install

echo "create jar"
mvn compile assembly:single
