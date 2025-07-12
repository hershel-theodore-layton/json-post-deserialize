#!/bin/bash

# Warm-up
for run in {1..10}; do
  curl --silent http://localhost:8080/bin/bench.hack?mode=both
done

echo "Start..."

for run in {1..1000}; do
  curl --silent http://localhost:8080/bin/bench.hack?mode=both >> bin/bench-results.txt
done

for run in {1..1000}; do
  curl --silent http://localhost:8080/bin/bench.hack?mode=parse >> bin/bench-results.txt
done

for run in {1..1000}; do
  curl --silent http://localhost:8080/bin/bench.hack?mode=reject >> bin/bench-results.txt
done
