#!/bin/sh

# creates the zip file from the src
zip -r -j lambda/lambda_function.zip src/*
# will attempt to apply changes
terraform apply -auto-approve