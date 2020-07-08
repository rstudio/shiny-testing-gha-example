library(shinytest)
expect_pass(testApp(
  "../",
  suffix = strsplit(utils::osVersion, " ")[[1]][1]
))
