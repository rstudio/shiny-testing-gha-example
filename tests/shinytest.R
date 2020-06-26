library(shinytest)
shinytest::expect_pass(
  shinytest::testApp("../", interactive = FALSE)
)
