#!/bin/bash
shopt -s extglob
base="step|stage|pipeline"
orig_include=`pwd`

#top level
for d in $orig_include/@($base)
do
    template_type=$(basename $d)
    echo "$template_type:"
    # techology
    for e in $template_type/*
    do
        tech=$(basename $e)
        echo "|- $tech:"
        #yaml files
        for f in $tech/*
        do
            file=$(basename $f)
            #full path
            echo "|-- $template_type/$tech/$file"
        done
    done
done
