#!/bin/sh

rm *.js
rm test/*.js

#mocha -R spec --compilers coffee:coffee-script/register

coffee -c *.coffee
coffee -c test/*.coffee

istanbul cover _mocha

#browserify csv.js -o csv.js