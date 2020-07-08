library(shinytest)
expect_pass(testApp("../", compareImages = grepl("^macOS", utils::osVersion)))
