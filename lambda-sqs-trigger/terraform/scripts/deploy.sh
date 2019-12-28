#!/bin/sh

# creates the zip file from the src
rm lambda_function.zip
zip -r -j lambda_function.zip src/*
# will attempt to apply changes
terraform apply -auto-approve