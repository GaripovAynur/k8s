#!/bin/bash
now=$(date +"%m-%d-%y")
 git pull
 git add .
 git commit -m "$now"
 git push
