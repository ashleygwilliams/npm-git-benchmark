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
- the npm Registry allows you to easily take advantage of semantic versioning
- the npm Registry is faster than GitHub
- the npm Registry only installs the files you need, and therefore uses less disk space

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
difference do those differing product goals make? 

### Semantic Versioning

Looking at the above example, you might be quick to note that using a `git` dependency means
that you need to replace the semver range indication for that dependency. One of the main
drawbacks to using a `git` dependency is that you cannot leverage semantic versioning. If you
use a `git` dependency you can pin to a commit or a branch, but you can't use the language
of semver to describe that decision. One of the drawbacks is that it's much harder for you
and other devs to communicate and understand the version of that dependency your application
needs. It also means that things like patch or minor release updates to that dependency won't
be automatically brought into your application, the way a dependency that was specified as
`^X.0.0` in your `package.json` (the default) might. In the end, using a `git` url to specify
a dependency instead of a language specifically designed to do it will likely make your
team less productive.

### `npm install` Performance

Now, it's true that not everyone loves semantic versioning- it's a complicated and often
imperfect system, so the loss of that feature is not a deal breaker for everyone. Assuming
you were willing to forego semantic versioning, my next question was: given that the npm
registry is *designed* for installs, what is the difference in performance between installing
`git` vs npm dependencies.

I decided to write a test to see exactly what that difference was.

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

#### Results

The goal of this benchmark was to motivate users to use the npm registry for their
packages, and in particular, to note the performance cost of using private git repos
instead of private npm packages.

As of 14 November 2016, these were the results, as run on TravisCI, using `Node 4.6.2`
and `npm 3.10.9`:

```
----------------------------------- RESULTS (seconds) ----------------------------------
---------------------------------------------------------------------------------------- 
|                          |     angular2 | git-angular2 |      express |  git-express | 
|        _with_empty_cache |       18.267 |      135.720 |       10.100 |       28.067 | 
|         _with_all_cached |       13.640 |      112.033 |        7.273 |       17.243 | 
----------------------------------------------------------------------------------------
```

As you can see, applications using npm depdendencies were *much* faster than those using
`git` dependencies. In addition, caching is *much more* effective on npm dependencies
than `git` dependencies.

### `node_modules` Disk Usage

Speed is not the only factor when installing dependencies. If you've ever taken a gander at
your `node_modules` directory- you know there's a lot in there!

Because npm is designed to be a package manager, it allows package publishers the ability
to control the files that are contained in their packages- much the way a `.gitignore` file
allows developers to control what files are tracked by version control. Many package authors
choose to not include supporting files like tests, documentation, and example code in the
pubished packages- although they almost certainly include them in the version control for
the package's source.

This is a less well-known feature of npm, and I wasn't sure how widespread it's usage was- so
after running the speed benchmark, I was curious if I would see a difference in `node_modules`
disk usage between applications using `git` vs npm dependencies.

#### Results

Using `Node 4.6.2` and `npm 3.10.9` on OSX, I npm installed and ran `du` on the `node_modules`
directory for each library.

```
---------------------- RESULTS (bytes) ----------------------
-------------------------------------------------------------
|     angular2 | git-angular2 |      express |  git-express |
|       132440 |       833776 |        36872 |        43816 |
-------------------------------------------------------------
```

The numbers above really speak for themselves- `git` dependencies use significantly more disk
space than npm dependencies do.

## Conclusion

So- what to conclude from all of this?

Firstly- if you didn't know that you could use `git` dependencies with npm, now you do! There
are plenty of good reasons to use `git` dependencies, and npm is commited to not only ensuring
that the CLI always supports them, but also to continuously improving the performance of 
installing them.

That being said- if your team is looking for improved performace and reduced disk usage, among
other boons, you'll want to leverage the npm registry. In summary, the npm registry offers
an improved performance over `git` dependencies because: 

- the npm Registry is specifically designed for serving packages
- the npm Registry allows you to easily take advantage of semantic versioning
- the npm Registry is faster than GitHub
- the npm Registry only installs the files you need, and therefore uses less disk space

If you're currently using private `git` repos as dependencies in your application, I'd strongly
encourage you to take a look at npm's private packages and orgs products- in addition to making
your team more productive, you'll be supporting the open source npm ecosystem and the
javascript community- and who doesn't like doing that?

Oh, and if you aren't a fan of warm fuzzies- how about never having to worry about this again?

![tweet about github being down]()
