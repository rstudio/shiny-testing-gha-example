
# Shiny App Testing using GitHub Actions

<!-- badges: start -->
[![R build status](https://github.com/rstudio/shiny-testing-gha-example/workflows/run-tests/badge.svg)](https://github.com/rstudio/shiny-testing-gha-example/actions)
<!-- badges: end -->

`shiny::runTests()` was added in shiny `v1.5.0`.  This function tests a `shiny` application (ex: `app.R`) using all `.R` files in the base of level of the `./tests` directory.

In 2020, [GitHub Actions](https://github.com/features/actions) supported launching [`macOS`, `Windows`, and `Linux` virtual machines](https://github.com/actions/virtual-environments) for continuous integration. Using [`r-lib/actions`](https://github.com/r-lib/actions) to set up our testing environments, we can test R packages and shiny applications on all three platforms symultaniously.

There are multiple levels of testing, each with their own pros and cons.  To view the different testing setups, click the links below:

* **Minimal:** `testthat` only
  * **GitHub Branch:** [`rstudio/shiny-testing-gha-example@testthat_only`](https://github.com/rstudio/shiny-testing-gha-example/tree/testthat_only)
  * **Pros:**
    * Quick to install
    * Can test server code using `shiny::testServer()`
  * **Cons:**
    * `shiny::testServer()` can not test the Shiny UI
    * No snapshot testing using `shinytest`

* **Single platform snapshot:** `testthat` + `shinytest` w/ snapshots on single platform (**\*\*suggested\*\***)
  * **GitHub Branch:** [`rstudio/shiny-testing-gha-example@single_platform_snapshot`](https://github.com/rstudio/shiny-testing-gha-example/tree/single_platform_snapshot)
  * **Compare:** [`Minimal` to `Single platform snapshot`](https://github.com/rstudio/shiny-testing-gha-example/compare/testthat_only...single_platform_snapshot)
  * **Pro:**
    * All benefits of `Minimal` testing
    * Test using `shinytest`
    * Snapshots with `shinytest` on a single platform
  * **Con:**
    * Only perform `shinytest` snapshot testing on a single platform

* **Multi platform snapshot:** `testthat` + `shinytest` w/ snapshots on all platforms
  * **GitHub Branch:** [`rstudio/shiny-testing-gha-example@multi_platform_snapshot`](https://github.com/rstudio/shiny-testing-gha-example/tree/multi_platform_snapshot)
  * **Compare:** [`Single platform snapshot` to `Multi platform snapshot`](https://github.com/rstudio/shiny-testing-gha-example/compare/single_platform_snapshot...multi_platform_snapshot)
  * **Pro:**
    * All benefits of `Single platform snapshot`
    * Performs snapshots on 3 platforms
  * **Con:**
    * More files to manage
    * Can not debug other platform images locally, only through GitHub Actions
      * Requires downloading zip files and manually copying in expected values
    * Takes more time to manage
      * Slow iteration time; ~ 10 mins for *broken* builds


For developers who host their applications, use the `Single platform snapshot` setup.  Your applications will be run on `Linux` only in production.

For developers who will have users run their applications locally, use the `Multi platform snapshots`. However, I do not believe it is worth the effort to maintain all `shinytest` platform images. The process is currently slow and tedious but may be of benefit to your application.  Instead, use `Single platform snapshot`.

## Use this repo as a template

To kick-start your shiny application testing on GitHub, click the green `Use this template` button to create a fresh GitHub repository with the full shiny application template and `Single platform snapshot` GitHub Action workflow file enabled by default. (Do **not** select `Include all branches` when using this template.)

See instructions on how to [`Create a repository from a template`](https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/creating-a-repository-from-a-template).

----------------------------


# Steps to reproduce this branch

This repo serves as an example of how to test your shiny application.

Features in this branch:
* Continuous Integration using GitHub Actions
* Template app from `shiny`
* Testing
  * `input` and `output` testing with `shinytest`
  * Snapshot testing with `shinytest` on all platforms
  * Server code testing with `testthat`

Please follow the steps below where you see fit to test your shiny application.

## Set up App

Initialize a shiny application so we have something to work with...

```r
# Set up a new app with everything
shiny::shinyAppTemplate(".", examples = "all")
```

If you already have a shiny application ready, set up testing for your application by calling:

```r
shiny::shinyAppTemplate(".", examples = c("shinytest", "testthat"))
```


## `shinytest`

To learn more about `shinytest`, please [see `Getting Started with shinytest`](https://rstudio.github.io/shinytest/articles/shinytest.html).

`shinytest` performs visual testing in addition to `input` and `output` validations. These tests should be initialized on your local machine before testing GitHub Actions.  Be sure to run `shiny::runTests()` and save the results to your repo before testing on GitHub Actions!

The images produced by `shinytest` will most likely be incorrect if the R version and/or operating system is changed. This is caused by subtle differences in how plots are produced and the default fonts of each system. Being off by one pixel will result in a failure in `shinytest`.  Remember, snapshots are being captured using `phantomjs`, not the default platform browser.


To test `shinytest` snapshots on multiple platforms, we will set a `suffix` value to the running platform: `macOS`, `Windows`, and `Ubuntu`.

```r
# ./tests/shinytest.R

library(shinytest)
expect_pass(testApp(
  "../",
  suffix = strsplit(utils::osVersion, " ")[[1]][1]
))
```

Note: Duplicate your local `shinytest` baselines to the other testing folder suffix values. Ex: `mytest-expected-macOS` to `mytest-expected-Ubuntu` and `mytest-expected-Windows`.  This will allow for GitHub Actions to fail and post the expected images for each platform.  If no baselines are found, shinytest will disclare the run a success and move `mytest-current` to `mytest-expected-SUFFIX`.


### Resolving `shinytest` failures

If a testing failure is produced by `shinytest`, the workflow file is configured to upload the `./tests` folder as [an artifact](https://docs.github.com/en/actions/configuring-and-managing-workflows/persisting-workflow-data-using-artifacts).

To fix your `shinytest` test, you MUST:
* manually download the failed test artifact,
* copy in the `*-current` folder,
* call `shinytest::viewTestDiff()` to resolve the test differences,
* and delete the `*-current` folder.

Once the tests have been updated, commit and push the updated files to GitHub.  Do not maintain any `*-current` folders (ex: `mytest-current`), only maintain `*-expected` folders (ex: `mytest-expected`).

(Repeat these steps as necessary.)


## GitHub Actions

#### Use a `DESCRIPTION` file

To integrate with GitHub Actions, we should use a `./DESCRIPTION` file. This will allow us to install necessary packages for running the application and for testing the application.

Packages needed to run the application should be put in `Imports`.  Packages needed for testing the application should be put in `Suggests`.  Use the `renv` package to help find all package dependencies being used in your application: `unique(renv::dependencies()$Package)`.


```r
usethis::use_description() # Initialize description file
usethis::use_package("shiny") # required to run app. (Imports)
usethis::use_package("shinytest", "Suggests") # testing only
usethis::use_package("testthat", "Suggests") # testing only
```

From here, feel free to manually adjust the title, description, authors, etc. This will not affect testing your application testing.


### Copy

To download this repo's workflow file, run:

```r
usethis::use_github_action(
  url = "https://raw.githubusercontent.com/rstudio/shiny-testing-gha-example/multi_platform_snapshot/.github/workflows/run-tests.yaml"
)
```

### Manual

To produce this repo's workflow file manually, follow these steps:

* Initialize from a standard `R CMD Check` workflow:
```r
usethis::use_github_action_check_standard("run-tests.yaml")
```
* Change job name and workflow name from `R-CMD-Check` to `run-tests`
```yaml
name: run-tests

jobs:
  run-tests:
```
* Remove any `r: 'devel'` matrix configurations. These are not beneficial for application testing.
* In `run-tests.yaml`, change `Check` step to:
```yaml
      - name: Run tests
        shell: Rscript {0}
        run: |
          shiny::runTests(".", assert = TRUE)
```
* Remove installation of `rcmdcheck` in `Install dependencies`
* In `run-tests.yaml`, change `Upload check results` step to:
```yaml
      - name: Upload test results
        if: failure()
        uses: actions/upload-artifact@master
        with:
          name: ${{ runner.os }}-r${{ matrix.config.r }}-tests
          path: tests
```
* Install `phantomjs` after the `Install dependencies` step:
```yaml
      - name: Find PhantomJS path
        id: phantomjs
        run: |
          echo "::set-output name=path::$(Rscript -e 'cat(shinytest:::phantom_paths()[[1]])')"
      - name: Cache PhantomJS
        uses: actions/cache@v1
        with:
          path: ${{ steps.phantomjs.outputs.path }}
          key: ${{ runner.os }}-phantomjs
          restore-keys: ${{ runner.os }}-phantomjs
      - name: Install PhantomJS
        shell: Rscript {0}
        run: |
          options(install.packages.check.source = "no")
          if (!shinytest::dependenciesInstalled()) shinytest::installDependencies()
```
* Before doing any other steps, make sure Windows does not convert any line endings from `\n` to `\r\n`. This helps when comparing json files on Windows.
```yaml
      # do not convert line feeds in windows
      - name: Windows git setup
        if: runner.os == 'Windows'
        run:
          git config --global core.autocrlf false
```


# File Structure

File structure of testing application:


<!-- tree -a -I ".git|.DS_Store" -->
```
├── .Rbuildignore
├── .github
│   ├── .gitignore
│   └── workflows
│       └── run-tests.yaml
├── DESCRIPTION
├── LICENSE
├── LICENSE.md
├── R
│   ├── example-module.R
│   └── example.R
├── README.md
├── app.R
└── tests
    ├── shinytest
    │   ├── mytest-expected-Ubuntu
    │   │   ├── 001.json
    │   │   ├── 001.png
    │   │   ├── 002.json
    │   │   └── 002.png
    │   ├── mytest-expected-Windows
    │   │   ├── 001.json
    │   │   ├── 001.png
    │   │   ├── 002.json
    │   │   └── 002.png
    │   ├── mytest-expected-macOS
    │   │   ├── 001.json
    │   │   ├── 001.png
    │   │   ├── 002.json
    │   │   └── 002.png
    │   └── mytest.R
    ├── shinytest.R
    ├── testthat
    │   ├── test-examplemodule.R
    │   ├── test-server.R
    │   └── test-sort.R
    └── testthat.R
```
