# Tests for the fixes in #51

test_that("writeSim2netCDF() has no default folder", {
  df <- data.frame(lon = 30, lat = 20, time = 2001:2003, dbh_total = 1:3)
  expect_error(writeSim2netCDF(df), "folder")
})

test_that("plotPROFOUND.TREE() and plotPROFOUND.STAND() restore par() with several species", {
  pdf(NULL)
  on.exit(dev.off())
  data <- data.frame(species = rep(c("a", "b"), each = 4), year = rep(2001:2002, 4),
                     dbh1_cm = 1:8, height1_m = 2:9, ba_m2ha = 1:8, density_treeha = 8:1)
  tmp <- list(data = data, automaticPanels = TRUE)
  ProfoundData:::plotPROFOUND.TREE(tmp)
  expect_equal(par("mfrow"), c(1, 1))
  ProfoundData:::plotPROFOUND.STAND(tmp)
  expect_equal(par("mfrow"), c(1, 1))
})

test_that("getData(), plotData() and summarizeData() pass on the error of parseQuery()", {
  skip_if_not(file.exists(databaseLocation), "PROFOUND_DB does not point to the database")
  skip_on_cran()
  setDB(db_name = databaseLocation)
  msg <- "Invalid site. Please use browseData to see the available sites"
  expect_error(getData("CLIMATE_LOCAL", site = "nosite"), msg, fixed = TRUE)
  expect_error(plotData("CLIMATE_LOCAL", site = "nosite"), msg, fixed = TRUE)
  expect_error(suppressMessages(summarizeData("CLIMATE_LOCAL", site = "nosite")), msg, fixed = TRUE)
  expect_error(getData("POLICY"), "Use browseData for", fixed = TRUE)
})
