#!/bin/bash

JAVA_VERSION="1.8"

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
