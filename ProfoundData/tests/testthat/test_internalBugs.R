# Tests for the bugs fixed in #46

test_that("FLUX daily summary builds dates as year-month-day", {
  data <- data.frame(site = "soro", site_id = 1, year = 1996, mo = 1, day = c(2, 2, 13),
                     neeCutRef_umolCO2m2s1 = 1:3)
  x <- ProfoundData:::summarizePROFOUND.FLUX(data, by = "day")
  expect_equal(x$date, as.Date(c("1996-01-02", "1996-01-13")))
})

test_that("writeSim2netCDF() keeps decimal latitudes and reports failures", {
  folder <- file.path(tempdir(), "i46")
  dir.create(folder)
  on.exit(unlink(folder, recursive = TRUE))
  df <- data.frame(lon = 30.5, lat = 20.7, time = c(1920, 1930, 1940), dbh_piab = 1:3)
  expect_true(writeSim2netCDF(df, folder = folder))
  f <- list.files(folder, pattern = "nc$", full.names = TRUE)
  expect_length(f, 1)
  nc <- RNetCDF::open.nc(f)
  lat <- RNetCDF::var.get.nc(nc, "lat")
  label <- RNetCDF::att.get.nc(nc, "dbh_piab", "long_field_name")
  units <- try(RNetCDF::att.get.nc(nc, "lat", "units"), silent = TRUE)
  RNetCDF::close.nc(nc)
  expect_equal(lat, 20.7, tolerance = 1e-6)
  expect_equal(label, "Mean DBH Picea abies")
  expect_equal(units, "degrees_north")

  expect_false(suppressMessages(writeSim2netCDF(df[, c(2, 1, 3, 4)], folder = folder)))
})

test_that("getDatasets(), queryDB() and summarizeData(by = 'day') with the database", {
  skip_if_not(file.exists(Sys.getenv("PROFOUND_DB")))
  setDB(Sys.getenv("PROFOUND_DB"))
  expect_false(any(grepl("_[0-9]|OVERVIEW", getDatasets())))
  expect_error(suppressMessages(queryDB("SELECT * FROM NOTATABLE")),
               "Error when querying: SELECT * FROM NOTATABLE", fixed = TRUE)
  x <- suppressMessages(summarizeData(dataset = "FLUX", site = "soro", by = "day"))
  expect_false(anyNA(x$date))
})
