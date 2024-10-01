#!/bin/bash
#ls -latr /run/secrets/hugging_face
set -e
huggingface-cli login --token `cat /run/secrets/hugging_face`

# now lets create a dataset
huggingface-cli repo create o1js-peformance-results --type dataset --organization introspector -y || echo fail

# now lets upload some results
huggingface-cli upload introspector/o1js-peformance-results ./output/.clinic  --repo-type dataset
