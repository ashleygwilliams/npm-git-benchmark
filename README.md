# npm-github-benchmark

Bash script for comparing performance of the npm CLI on registry and git deps

## Run the benchmarking

```
./benchmark.sh
```

By default it will run twice each installation, use `-n` to change the number of iterations.

```
./benchmark.sh -n 10
```

The test is run by installing angular2, ember and react N times. Each series is run twice, the
first time cleaning the cache in every run and the second one using the cache.
