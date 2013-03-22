#!/bin/zsh
for dir in *(/);do
    for file in $dir/*ttl;do
        base=$(basename $file)
        sans_ttl=$(echo $base|sed 's/.ttl$//')
        echo cp $file ${sans_ttl}_${dir}.ttl;
    done
done
