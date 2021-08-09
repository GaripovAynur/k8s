#!/bin/bash
now=$(date +"%m-%d-%y")
 git pull
 git add .
 git commit -am "$now"
 git push
