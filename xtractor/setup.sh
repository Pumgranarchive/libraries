#!/bin/bash

JAVA_VERSION="1.8"

if [ ! -d "lib/xtractor" ]; then

    mkdir -p lib
    git clone git@github.com:mohaps/xtractor.git lib/xtractor
    cd lib/xtractor
    mvn clean install -Dmaven.compiler.source=$JAVA_VERSION -Dmaven.compiler.target=$JAVA_VERSION

fi
