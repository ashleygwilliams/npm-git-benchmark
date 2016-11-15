# npm-git-benchmark
> Bash script for comparing performance of the npm CLI on registry and git deps

This script runs a benchmark on the length of time an `npm install` takes depending
on whether the primary dependencies are git dependencies (fetched from GitHub) or
npm dependencies (fetched from the npm registry). For added comparison, it also runs
tests to see the effect caching has on both scenarios.

## Results

The goal of this benchmark was to motivate users to use the npm registry for their
packages, and in particular, to note the performance cost of using private git repos
instead of private npm packages.

As of 14 November 2015, these were the results, as run on TravisCI, using `Node 4.6.2`
and `npm 3.10.9`:

### Speed

```
----------------------------------- RESULTS (seconds) ----------------------------------
---------------------------------------------------------------------------------------- 
|                          |     angular2 | git-angular2 |      express |  git-express | 
|        _with_empty_cache |       18.267 |      135.720 |       10.100 |       28.067 | 
|         _with_all_cached |       13.640 |      112.033 |        7.273 |       17.243 | 
----------------------------------------------------------------------------------------
```

### Size

Using `Node 4.6.2` and `npm 3.10.9` on OSX, I npm installed and ran `du` on the `node_modules`
directory for each library.

```
---------------------- RESULTS (bytes) ----------------------
-------------------------------------------------------------
|     angular2 | git-angular2 |      express |  git-express |
|       132440 |       833776 |        36872 |        43816 |
-------------------------------------------------------------
```

# Try it Yourself

## Prerequisites

This script requires a true Linux. Any Linux seems to be fine, but notably it
fails on OS X.

## Up and Running

1. Fork and clone this repository.
2. `cd npm-git-benchmark`
3. `./benchmark.sh`

