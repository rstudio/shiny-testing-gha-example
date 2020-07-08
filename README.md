
# Shiny App Testing using GitHub Actions

<!-- badges: start -->
[![R build status](https://github.com/rstudio/shiny-testing-gha-example/workflows/run-tests/badge.svg)](https://github.com/rstudio/shiny-testing-gha-example/actions)
<!-- badges: end -->

`shiny::runTests()` was added in shiny `v1.5.0`.  This function tests a `shiny` application (ex: `app.R`) using all `.R` files in the base of level of the `./tests` directory.

In 2020, [GitHub Actions](https://github.com/features/actions) supported launching [`macOS`, `Windows`, and `Linux` virtual machines](https://github.com/actions/virtual-environments) for continuous integration. Using [`r-lib/actions`](https://github.com/r-lib/actions) to set up our testing environments, we can test R packages and shiny applications on all three platforms symultaniously.

There are multiple levels of testing, each with their own pros and cons.  To view the different testing setups, click the links below:

Cost / Benefit
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
  * Server code testing with `testthat`

Please follow the steps below where you see fit to test your shiny application.

## Set up App

Initialize a shiny application so we have something to work with...

```r
# Set up a new app with everything but shinytest
shiny::shinyAppTemplate(".", examples = c("app", "rdir", "module", "testthat"))
```


## Use a `DESCRIPTION` file

To integrate with GitHub Actions, we should use a `./DESCRIPTION` file. This will allow us to install necessary packages for running the application and for testing the application.

Packages needed to run the application should be put in `Imports`.  Packages needed for testing the application should be put in `Suggests`.  Use the `renv` package to help find all package dependencies being used in your application: `unique(renv::dependencies()$Package)`.


```r
usethis::use_description() # Initialize description file
usethis::use_package("shiny") # required to run app. (Imports)
usethis::use_package("testthat", "Suggests") # testing only
```

From here, feel free to manually adjust the title, description, authors, etc. This will not affect testing your application testing.

## GitHub Actions

### Copy

To download this repo's workflow file, run:

```r
usethis::use_github_action(
  url = "https://raw.githubusercontent.com/rstudio/shiny-testing-gha-example/minimal/.github/workflows/run-tests.yaml"
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
    ├── testthat
    │   ├── test-examplemodule.R
    │   ├── test-server.R
    │   └── test-sort.R
    └── testthat.R
```
