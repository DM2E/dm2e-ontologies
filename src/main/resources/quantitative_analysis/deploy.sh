#!/bin/bash

index=out/index.html
touch $index
rm $index
touch $index
echo '<html><body><ul>' >> $index;
for i in out/*;do
    i=$(basename $i)
    echo "<li><a href='$i'>$i</a></li>" >> $index
done
echo '<ul><body><html>' >> $index;

rm /var/lib/tomcat7/webapps/data/static/visualize/*
cp out/* /var/lib/tomcat7/webapps/data/static/visualize/
chown tomcat7 /var/lib/tomcat7/webapps/data/static/visualize/*
