
# Shiny App Testing using GitHub Actions

<!-- badges: start -->
[![R build status](https://github.com/rstudio/shiny-testing-gha-example/workflows/run-tests/badge.svg)](https://github.com/rstudio/shiny-testing-gha-example/actions)
<!-- badges: end -->

`shiny::runTests()` was added in shiny `v1.5.0`.  This function tests a `shiny` application (ex: `app.R`) using all `.R` files in the base of level of the `./tests` directory.

In 2020, [GitHub Actions](https://github.com/features/actions) supported launching [`macOS`, `Windows`, and `Linux` virtual machines](https://github.com/actions/virtual-environments) for continuous integration. Using [`r-lib/actions`](https://github.com/r-lib/actions) to set up our testing environments, we can test R packages and shiny applications on all three platforms symultaniously.

This repo serves as an example of how to test your shiny application.

Features:
* Continuous Integration using GitHub Actions
* Template app from `shiny`
* Testing
  * Server code testing with `testthat`


# Steps to reproduce

Please follow the steps below where you see fit to test your shiny application.


## Set up App

Initialize a shiny application so we have something to work with...

```r
# Set up a new app with everything but shinytest
shiny::shinyAppTemplate(".", examples = c("app", "rdir", "module", "testthat"))
```


## Use a `DESCRIPTION` file

To integrate with GitHub Actions, we should use a `./DESCRIPTION` file. This will allow us to install necessary packages for running the application and for testing the application.

Packages needed to run the application should be put in `Imports`.  Packages needed for testing the application should be put in `Suggests`.


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
  url = "https://raw.githubusercontent.com/rstudio/shiny-testing-gha-example/master/.github/workflows/run-tests.yaml"
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
