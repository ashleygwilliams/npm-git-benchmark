# npm-git-benchmark
> Bash script for comparing performance of the npm CLI on registry and git deps

This repo contains a bash script for comparing the performance of an `npm install`
on dependencies retrieved from the npm Registry or from GitHub, via `git`
dependencies. 

It runs the following 4 scenarios for 2 packages, `express` and `angular2`:

- `npm install` with no cache (`npm cache clear`) on dependecies fetched from the npm registry
- `npm install --cache-min 999999` (using the cache) on dependencies fetched from the npm registry
- `npm install` cache-min` with no cache (`npm cache clear`) on depedencies fetched from GitHub
- `npm install --cache-min 999999` (using the cache) on depdnecies fetched from Github 

In summary, this script runs a benchmark on the length of time an `npm install` takes depending
on whether the primary dependencies are git dependencies (fetched from GitHub) or
npm dependencies (fetched from the npm registry). For added comparison, it also runs
tests to see the effect caching has on both scenarios.

## Background and Results

For more background and results, please see [ANALYSIS.md](ANALYSIS.md).

## Up and Running

This is a bash script that runs on most Linux distros. You'll need a Linux of some type to
run it; OSX is not currently supported.

To run the benchmark, simply type:

```
./benchmark.sh
```
