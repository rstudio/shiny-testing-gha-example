library(shinytest)
shinytest::expect_pass(
  shinytest::testApp(
    "../",
    interactive = FALSE,
    suffix = strsplit(sessioninfo::os_name(), " ")[[1]][1]
  )
)
