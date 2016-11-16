# npm-git-benchmark
> Bash script for comparing performance of the npm CLI on registry and git deps

npm is a package manager for many (mostly web dev-y, javascript-y) things, which is
to say, that npm is a collection of humans and software that make the publishing and
usage of things called "packages" easier for other humans and software.

Part of the software that npm consists of is a registry, which is where a lot of the
packages that npm users install live- 370,000+, in fact- but this is not where all of 
them live.

As part of npm's commitment to open source, npm has always allowed user to set up
alternative regsitries to publish packages to and install packages from. This is 
partly how npmE, npm's enterprise product, works- however there are many more 
examples of alternative registries out in the wild.

## `git` Dependencies

In addition to the option to use alternative registries, npm also supports using a
`git` address to point to packages stored on version control hosting, such as GitHub.
You can use this functionality alongside the npm registry (or another registry of your
choosing). For example, you could have a `package.json` that looks like this:

```json
{
  "name": "my-awesome-app",
  "version": "3.0.0",
  "description": "there's an app for that- and this is it!",
  "main": "index.js",
  "author": "ag_dubs <ashley@npmjs.com>",
  "license": "ISC",
  "dependencies": {
    "express": "^4.14.0",
    "my-secret-auth-package": "git@github.com:ashleygwilliams/my-secret-auth-package.git"
  }
}
```

If you and your company are already using GitHub, or something like it, for version
control, it might occur to you that using it as your package registry would be a 
simple solution- particularly if you are already paying GitHub for private repositories!

A question we get at npm a lot is- why should I pay for private packages when I can simply
use a private GitHub registry? The rest of this article aims to answer that question- but
here's a quick rundown:

- the npm Registry is specifically designed for serving packages
- the npm Registry is faster than GitHub
- the npm Registry only installs the files you need, and therefore uses less disk space
- the npm Registry allows you to easily take advantage of semantic versioning

## The Right Tool For the Job

> npm would be a terrible version control service.
> - C.J. Silvero, CTO, npm, Inc

Remember how I described npm as a collection of software and humans earlier? This was a 
deliberately strange move on my part. This is primarily because many people do not realize
that npm extends beyond the CLI tool you use to type `npm install` into your terminal.
npm is a company- with lots of people, working on lots of different things! The npm CLI is
just one product among many.

In fact, the main product at npm is the npm Registry- a very large and semi-elaborate set
of services that enable both the CLI client and the website to function. Long ago, the npm
Registry used to be a simple CouchApp built on top of CouchDB- but over the years, it has
grown and changed, specifically for the purposes of improving uptime and performance.

Last year the npm registry served X downloads, grew to contain X packages, X users, and had
a downtime of X%.

## `git` vs npm Registry Showdown!

There's no question that npm is specifically designed to serve all the uses a package
manager could need- but GitHub is a version control and collaboration product! Many of us
know and love it, but it *isn't* designed to be a package manager. How much of a
difference do those differing product goals make? I decided to write a test to see
exactly what that difference was.

I took two common and popular frameworks, `express` and `angular2`, copied their
`package.json`s, and then made a version for each where I replaced all the primary
dependencies with `git` URLs. Then I wrote a shell script which timed the following
sitations using the `time` utility:

- `npm install` with no cache (`npm cache clear`) on dependecies fetched from the npm registry
- `npm install --cache-min 999999` (using the cache) on dependencies fetched from the npm registry
- `npm install` cache-min` with no cache (`npm cache clear`) on depedencies fetched from GitHub
- `npm install --cache-min 999999` (using the cache) on depdnecies fetched from Github 

In summary, this script runs a benchmark on the length of time an `npm install` takes depending
on whether the primary dependencies are git dependencies (fetched from GitHub) or
npm dependencies (fetched from the npm registry). For added comparison, it also runs
tests to see the effect caching has on both scenarios.

## Results

The goal of this benchmark was to motivate users to use the npm registry for their
packages, and in particular, to note the performance cost of using private git repos
instead of private npm packages.

As of 14 November 2016, these were the results, as run on TravisCI, using `Node 4.6.2`
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

