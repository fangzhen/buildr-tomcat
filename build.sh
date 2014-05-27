#! /bin/bash

cd java
buildr compile
cp -Rf target/classes/com ../lib
cd ..
gem build buildr-tomcat.gemspec
