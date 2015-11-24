#!/bin/bash

JAVA_VERSION=`java -version 2>&1 | head -n 1 | awk -F'"' '{print $2}' | sed -r 's/\.([0-9]+)_([0-9]+)$//g'`

if [ ! -d "lib/xtractor" ]; then

    mkdir -p lib
    # git clone https://github.com/mohaps/xtractor.git lib/xtractor
    git clone https://github.com/ArnaudParant/xtractor.git lib/xtractor
    cd lib/xtractor
    git checkout optimized
    sudo apt-cache search maven
    sudo apt-get install maven
    mvn clean install -Dmaven.compiler.source=$JAVA_VERSION -Dmaven.compiler.target=$JAVA_VERSION

fi
