#!/bin/bash

echo "Stop innovad"
innovad stop

cd innova
git checkout master
git pull
cd src
make -f makefile.unix
mv ~/innova/src/innovad /usr/local/bin/innovad

echo "Start innovad"
innovad
watch -n 10 'innovad getinfo'
