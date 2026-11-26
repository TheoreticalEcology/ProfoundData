# Database and argument checks (#53) and the main functions on a small synthetic database (#55);
# no PROFOUND database needed

test_that("setDB() accepts only PROFOUND databases; a missing database gives a clear error", {
  old <- ProfoundData:::dbConnection()
  on.exit(do.call(ProfoundData:::dbConnection, old))
  db <- makeTestDB()

  settings::reset(ProfoundData:::dbConnection)
  expect_error(browseData(), "No PROFOUND database is registered")
  expect_error(setDB(), "Please provide db_name")  # no file dialog in non-interactive sessions

  empty <- tempfile(fileext = ".sqlite"); file.create(empty)
  text <- tempfile(fileext = ".sqlite"); writeLines("no database", text)
  expect_error(setDB(empty), "Not a PROFOUND database")
  expect_error(setDB(text), "Not a PROFOUND database")
  expect_error(setDB(file.path(tempdir(), "missing.sqlite")), "valid path")
  expect_error(setDB(tempdir()), "valid path")
  expect_error(browseData(), "No PROFOUND database is registered") # failed setDB() registers nothing

  # any file name; relative paths are stored as absolute paths
  db2 <- file.path(tempdir(), "profound.db"); file.copy(db, db2)
  wd <- setwd(tempdir())
  setDB("profound.db")
  setwd(wd)
  expect_equal(getDB(), normalizePath(db2, winslash = "/"))

  # the database is opened read-only, and the connection is closed after a failed query
  expect_error(queryDB("DROP TABLE SITES"), "readonly")
  expect_error(queryDB("SELECT * FROM NOPE"), "no such table")
  expect_message(res <- queryDB("SELECT * FROM SITES WHERE site = 'nowhere'"), "no rows")
  expect_equal(nrow(res), 0)
  expect_true(file.remove(db2)) # fails on Windows if a connection is still open

  # a moved or deleted database is not replaced by an empty file
  expect_error(browseData(), "does not exist")
  expect_false(file.exists(db2))
})

test_that("data functions check dataset, site and period before querying", {
  old <- ProfoundData:::dbConnection()
  on.exit(do.call(ProfoundData:::dbConnection, old))
  setDB(makeTestDB())

  expect_error(getData(c("TREE", "STAND"), site = "soro"), "'dataset' must be a single")
  expect_error(getData("CLIMATE_LOCAL", site = c("soro", "hyytiala")), "'site' must be a single")
  expect_error(browseData(c("TREE", "STAND")), "'dataset' must be a single")
  expect_warning(expect_error(getData("ENERGY BALANCE", site = "soro"), "Invalid dataset"), "ATMOSPHERICHEATCONDUCTION")
  for (period in list("01.01.2000", "2000-02-30", "2000-01-01xyz", "99-01-01", 2000,
                      c("2000-01-01", "2000-06-01", "2001-01-01"), c(NA, NA)))
    expect_error(getData("CLIMATE_LOCAL", site = "soro", period = period), "Invalid period")

  x <- getData("CLIMATE_LOCAL", site = "soro", period = c("2000-03-01", "2000-03-10"))
  expect_equal(range(x$date), c("2000-03-01", "2000-03-10"))
  x <- getData("CLIMATE_LOCAL", site = "soro", period = c(NA, as.Date("2000-01-05")))
  expect_equal(range(x$date), c("2000-01-01", "2000-01-05"))
  x <- getData("CLIMATE_LOCAL", site = "soro", period = "2001-12-30")
  expect_equal(nrow(x), 2)
  x <- getData("CLIMATE_LOCAL", site = "soro", period = c("2001-12-30", NA))
  expect_equal(nrow(x), 2)
  x <- getData("CLIMATE_LOCAL", site = "soro", period = as.Date(c("2000-01-10", "2000-01-01")))
  expect_equal(range(x$date), c("2000-01-01", "2000-01-10"))
})

test_that("main functions work on the synthetic database", {
  old <- ProfoundData:::dbConnection()
  on.exit(do.call(ProfoundData:::dbConnection, old))
  setDB(makeTestDB())

  expect_equal(nrow(browseData()), 1)
  expect_equal(browseData("CLIMATE_LOCAL")$site, "soro")
  expect_equal(browseData(site = "soro", dataset = "CLIMATE_LOCAL"), 1)
  expect_error(browseData(site = "nowhere"), "browseData\\(\"SITES\"\\)")
  expect_true("CLIMATE_LOCAL" %in% browseData("DATASETS"))

  x <- getData("CLIMATE_LOCAL", site = "soro", variables = "p_mm")
  expect_equal(nrow(x), 731)
  expect_true("p_mm" %in% names(x) && !"tmean_degC" %in% names(x))
  expect_error(getData("FLUX", site = "soro"), "browseData")
  expect_equal(getData("SITES")$site, c("soro", "global"))

  s <- summarizeData("CLIMATE_LOCAL", site = "soro", by = "year")
  expect_equal(nrow(s), 2)

  pdf(NULL)
  on.exit(dev.off(), add = TRUE)
  expect_error(plotData("CLIMATE_LOCAL", site = "soro", variables = "tmean_degC"), NA)
})
