
# Shiny App Testing using GitHub Actions

<!-- badges: start -->
[![R build status](https://github.com/rstudio/shiny-testing-gha-example/workflows/run-tests/badge.svg)](https://github.com/rstudio/shiny-testing-gha-example/actions)
<!-- badges: end -->

## Overview

This repository contains several templates for Shiny testing with [GitHub Actions](https://github.com/features/actions). The different types of Shiny testing, namely unit (i.e., **testthat**), server (i.e., `shiny::testServer()`), and snapshot-based (i.e., **shinytest**) testing are described in the [Shiny testing overview article](https://shiny.rstudio.com/articles/testing-overview.html) (please read that first if you aren't already familiar with each type of testing). Due to trade-offs associated with the different types of Shiny testing, this repo offers three different templates, which are provided on different branches of this repo:

1. A [**minimal** template](https://github.com/rstudio/shiny-testing-gha-example/tree/minimal), which should be used only if unit and server testing fits your needs (that is, you don't need snapshot-based testing).
  * By default, this template (as well as the other templates) run tests [on Windows, MacOS, and Linux with the current release version of R](https://github.com/rstudio/shiny-testing-gha-example/blob/531bba7c/.github/workflows/run-tests.yaml#L15-L19). If you need to test more versions of R, you can add more entries to the `.github/workflow/run-test.yaml` file [like this](https://github.com/r-lib/usethis/blob/819867e0/.github/workflows/R-CMD-check.yaml#L21-L29).
2. All of (1), plus [snapshot-based testing on a **single** platform](https://github.com/rstudio/shiny-testing-gha-example/tree/single_platform_snapshot).
  * This template [adds](https://github.com/rstudio/shiny-testing-gha-example/compare/minimal...single_platform_snapshot) snapshot-based testing on MacOS. The [`tests/shinytest.R`](https://github.com/rstudio/shiny-testing-gha-example) file is what ensures that snapshot images are compared only on MacOS. If you wanted to compare on Windows or Linux instead, you can change the `grepl("^macOS", utils::osVersion)` to `grepl("^Windows", utils::osVersion)` or `grepl("^Ubuntu", utils::osVersion)`. If your local OS happens to match the target OS for CI testing, then you can `shinytest::testApp()` to generate the expected baselines; otherwise, you'll want to [view and approve them via GHA artifacts](#view-and-manage-test-results-test-results).
3. All of (1), plus [snapshot-based testing on a **multiple** platforms](https://github.com/rstudio/shiny-testing-gha-example/tree/multi_platform_snapshot).
  * This template [adds](https://github.com/rstudio/shiny-testing-gha-example/compare/minimal...multi_platform_snapshot) snapshot-based testing on Windows, MacOS, and Linux. Snapshot-based testing on multiple platforms requires maintaining multiple baselines for the same snapshot, so this template adds a [`suffix` to each baseline with the platform's name](https://github.com/rstudio/shiny-testing-gha-example/blob/7041eaa/tests/shinytest.R#L4) (you could also include the R version in the suffix if you need different baselines for different R versions). This means you'll want to set up workflow for [viewing and approving new baselines via GHA artifacts](#view-and-manage-test-results-test-results).

## Get started

### Choose a template

The templates described above are available through different branches of this repo. So, to choose a template, choose one of the branches from the dropdown at the top of this page (the default is template 2: snapshot testing on a single platform).

<div align="center">
  <img src="https://i.imgur.com/KozrU1V.png" width="300">
</div>

### Copy a template

#### New project

To copy a template to a _new_ GitHub repo, click the green `Use this template` button. This essentially copies this repo to your GitHub profile and kick off a [GHA workflow](https://github.com/rstudio/shiny-testing-gha-example/actions) ([see here](https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/creating-a-repository-from-a-template) for more details).

#### Existing project

To copy a template to an _existing_ GitHub repo, copy the `.github/workflows/run-tests.yaml` workflow file to your GitHub repo.

### Modify the app code and tests

After copying the template, it's time to start supplying your own app code (`app.R`), any supporting R code (`R/` directory), as well as any relevant `tests/`. Note that, when setting up snapshot based testing, you can overwrite the existing `tests/shinytest/` tests via `shinytest::recordTest()`. Once your tests are written (and recorded), make sure to run the tests (via `shiny::runTests()`) locally to make sure the tests pass locally and approve any new baselines.

As a side note, the app code and tests in this repo were provided by `shiny::shinyAppTemplate('.')`, which provides the `app.R`, `R/` and `tests/` examples. This function can also be useful if you want to add scaffolding for tests to an existing app by doing `shiny::shinyAppTemplate(".", examples = c("shinytest", "testthat"))`.

### Add R package dependencies

After supplying your own app code and tests, you'll need to make sure any supporting R packages are installed on the GHA machine(s). If you happen to already know what packages the app needs to run, you can add them to the `Imports` field of the `DESCRIPTION` file. If you don't already know, you can also call `renv::dependencies()` on the root of this directly, which should return all R packages that your app needs.

It's worth mentioning that some R packages require system libraries that aren't already available by default on the GHA machine. This shouldn't really be an issue for Linux since [system dependencies should automatically be installed](https://github.com/rstudio/shiny-testing-gha-example/blob/555dd40/.github/workflows/run-tests.yaml#L55-L62), but its currently more of a headache on Windows and MacOS. In the case of MacOS, [homebrew](https://brew.sh) is available, so if you need to install system dependencies for something like the **openssl** package, you can add the following to the `.github/workflows/run-tests.yaml` file:

```yaml
- name: Install system dependencies
  if: runner.os == 'macOS'
  run: |
    brew install openssl
```

### Change the authors, licensing, etc.

Finally, you'll want to edit the `LICENSE`, `LICENSE.md`, and `DESCRIPTION` files to contain suitable authors and copyright holders. Note also that the `DESCRIPTION` allows someone to `remotes::install_github()` on your repo to install all the R dependencies for your app, so you should also update the `Package`, `Title`, and `Description` fields to contain relevant info.

### View and manage test results

At this point, you're likely ready to start committing and pushing your code to a GitHub repo. This should trigger the `run-tests` workflow to run with your new code. To view the results, go to the "Actions" tab and click on the `run-tests` workflow, which will list every run of the workflow.

![](https://i.imgur.com/d5uMbid.png)

To view a particular run, click on particular commit. If any of the builds for a particular run happened to fail, you'll see some [build artifacts](https://docs.github.com/en/actions/configuring-and-managing-workflows/persisting-workflow-data-using-artifacts). These artifacts contain the contents of the `tests/` directory, which is primarily useful for resolving the snapshot-based test failures. To resolve other test failures, you'll have to refer to the build log (if you see something like `Not all shinytest scripts passed for ..` in the build log, then you have snapshot failures).

![](https://i.imgur.com/sC4TwEd.png)

To view the snapshot differences, download the artifacts, and replace your local `tests/` directory with the artifacts' `tests/`. You can then call `shinytest::viewTestDiff()` on the app directory to view (and potentially approve) the differences. After approving, the differences should be tracked in your git repo, making it so you can commit and push the changes to resolve the test failure(s).

### Testing multiple applications

All the templates provided here provide the scaffolding for testing a _single_ application. Here we'll demonstrate how to setup scaffolding for testing multiple apps. First off, let's use the GitHub Actions workflow for snapshot testing on a single platform:

```r
library(usethis)
use_github_action(
 url = "https://raw.githubusercontent.com/rstudio/shiny-testing-gha-example/single_platform_snapshot/.github/workflows/run-tests.yaml"
)
```

Next, lets use `shiny::shinyAppTemplate()` to set-up scaffolding for multiple apps, the first of which will have snapshot-based testing and the second of which only needs server testing:

```r
library(shiny)
shinyAppTemplate("app1", examples = c("app", "shinytest"))
shinyAppTemplate("app2", examples = c("app", "testthat"))
```

As a result, the file structure now looks something like:

```r
fs::dir_tree(all = TRUE)
```

```r
.
├── .github
│   ├── .gitignore
│   └── workflows
│       └── run-tests.yaml
├── app1
│   ├── app.R
│   └── tests
│       ├── shinytest
│       │   └── mytest.R
│       └── shinytest.R
└── app2
    ├── app.R
    └── tests
        ├── testthat
        │   └── test-server.R
        └── testthat.R
```

Now, to run tests over all the applications, we'll have to edit the `.github/workflows/run-tests.yaml` file to change `shiny::runTests(".", assert = TRUE)` to `lapply(c("app1", "app2"), shiny::runTests, assert = TRUE)` (or, if you'd rather not hard code the app directory names, do `lapply(dirname(Sys.glob("*/app.R")), shiny::runTests, assert = TRUE)`)

At this point, you could replace the app code and tests with your own, then put all the R dependencies in a top-level `DESCRIPTION` file, and that way the GHA workflow will know how to install all the R dependencies:

```r
pkgs <- paste(renv::dependencies()$Package, collapse = ",")
use_description(fields = list(Imports = pkgs))
```

### Using renv for reproducibility

If reproducibility is of utmost importance for your project, you may want to consider relying on [**renv**](https://rstudio.github.io/renv/articles/renv.html) instead of a `DESCRIPTION` file to "lock in" versions of the R packages that you're using. Note that if you do this, you'll have to add a step to your `.github/workflows/run-tests.yaml` to include something like:

```yaml
- name: Restore renv snapshot
  shell: Rscript {0}
  run: |
    if (!require('renv')) install.packages('renv')
    renv::restore()
```

Also, make sure to re-run `renv::snapshot()` on the development machine whenever you update packages locally to make sure the packages on GHA stay in sync.
