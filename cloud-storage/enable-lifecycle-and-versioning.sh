#!/bin/bash

BUCKET_NAME="piotrostr-resources-course-bucket"

gsutil lifecycle set life.json gs://$BUCKET_NAME
gsutil versioning set on gs://$BUCKET_NAME
