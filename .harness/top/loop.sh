#!/bin/bash
#
shopt -s extglob
base="step|stage|pipeline|stepgroup"
orig_include="/Users/lorenyeung/harness-yaml-templates/.harness/top"

#cd $orig_include
#top level
for d in $orig_include/@($base)
do
    template_type=$(basename $d)
    echo "$template_type:"
    # techology
    for e in ${d}/*
    do
        tech=$(basename $e)
        echo "|- $tech:"
        #yaml files
        for f in ${e}/*
        do
            file=$(basename $f)
            #full path
            echo $f
            echo "|-- $orig_include/$template_type/$tech/$file"
            # yq --exit-status=0 --expression='.template.identifier' $orig_include/$template_type/$tech/$file
            # yq --exit-status=0 --expression='.template.name' $orig_include/$template_type/$tech/$file
            # yq --exit-status=0 --expression='.template.versionLabel' $orig_include/$template_type/$tech/$file
            # yq --exit-status=0 --expression='.template.spec.description' $orig_include/$template_type/$tech/$file
            # yq --exit-status=0 --expression='.template.type' $orig_include/$template_type/$tech/$file
        done
    done
done
