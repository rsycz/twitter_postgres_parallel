#!/bin/bash
files=$(find data/*)
echo '================================================================================'
echo 'load denormalized'
echo '================================================================================'
time for file in $files; do
    unzip -p $file | python3 -c "
import sys
import json
for line in sys.stdin:
    line = line.strip().replace('\u0000', '')
    if line:
        tweet = json.loads(line)
        print(json.dumps(tweet))
" | psql postgresql://postgres:pass@localhost:1099 -c "\COPY tweets_jsonb (data) FROM STDIN WITH (FORMAT csv, quote e'\x01', delimiter e'\x02')"
done
echo '================================================================================'
echo 'load pg_normalized'
echo '================================================================================'
time for file in $files; do
    python3 -u load_tweets.py --db=postgresql://postgres:pass@localhost:10992 --inputs $file
done
echo '================================================================================'
echo 'load pg_normalized_batch'
echo '================================================================================'
time for file in $files; do
    python3 -u load_tweets_batch.py --db=postgresql://postgres:pass@localhost:10993 --inputs $file
done
