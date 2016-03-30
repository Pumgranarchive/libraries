#!/bin/bash

echo "y" | sudo apt-get install xsltproc make cmake gcc g++

export CMAKE_C_COMPILER=/usr/bin/gcc
export CMAKE_CXX_COMPILER=/usr/bin/g++
echo -e "# C / C++ setting\nexport CMAKE_C_COMPILER=/usr/bin/gcc\nexport CMAKE_CXX_COMPILER=/usr/bin/g++" >> ~/.bashrc

(cd /tmp/ && git clone https://github.com/w3c/tidy-html5.git && cd tidy-html5 && git checkout 032bf4264dfbf3c03751a3f7d8f7f9f12b4aa4c2 && cd build/cmake/ && cmake && make && sudo make install)
