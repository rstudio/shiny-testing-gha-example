library(shinytest)
<<<<<<< HEAD
expect_pass(testApp(
  "../",
  suffix = strsplit(utils::osVersion, " ")[[1]][1]
))
=======
expect_pass(testApp("../", compareImages = grepl("^macOS", utils::osVersion)))
>>>>>>> single_platform_snapshot
