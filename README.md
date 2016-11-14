# npm-git-benchmark

Bash script for comparing performance of the npm CLI on registry and git deps

## Run the benchmarking

```
./benchmark.sh
```

By default it will run each installation three times, use `-n` to change the number of iterations.

```
./benchmark.sh -n 10
```

This test runs npm install, with and without cache, for both angular2 and express, first using
dependencies from the npm registry, then using dependencies from git.
