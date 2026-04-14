#!/bin/bash
files=$(find data/*)

echo '================================================================================'
echo 'load pg_denormalized'
echo '================================================================================'
echo "$files" | parallel ./load_denormalized.sh

echo '================================================================================'
echo 'load pg_normalized'
echo '================================================================================'
echo "$files" | parallel python3 -u load_tweets.py --db=postgresql://postgres:pass@localhost:10992 --inputs

echo '================================================================================'
echo 'load pg_normalized_batch'
echo '================================================================================'
echo "$files" | parallel python3 -u load_tweets_batch.py --db=postgresql://postgres:pass@localhost:10993 --inputs
