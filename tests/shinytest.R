library(shinytest)
expect_pass(testApp("../", compareImages = grepl("^darwin", R.version$os))
