# Tests for downloadDatabase() and reportDB() without network access (#45)

test_that("downloadDatabase() does not write anything without location in non-interactive sessions", {
  skip_if(interactive())
  expect_error(downloadDatabase(), "Please provide 'location'")
  expect_error(downloadDatabase(location = file.path(tempdir(), "doesNotExist")), "does not exist")
})

test_that("downloadDatabase() returns an existing database without downloading", {
  dir <- tempfile("db")
  dir.create(dir)
  on.exit(unlink(dir, recursive = TRUE))
  sqlFile <- file.path(dir, "ProfoundData.sqlite")
  file.create(sqlFile)
  expect_message(res <- downloadDatabase(location = dir), "already exists")
  expect_equal(res, sqlFile)
  expect_false(file.exists(file.path(dir, "ProfoundData.zip")))
})

test_that("unzipDatabase() extracts the database and detects broken zip files", {
  skip_if(Sys.which("zip") == "", "no zip program to create the test file")
  src <- tempfile("src")
  dir.create(src)
  out <- tempfile("out")
  dir.create(out)
  on.exit(unlink(c(src, out), recursive = TRUE))
  writeLines(rep("PROFOUND", 1000), file.path(src, "ProfoundData.sqlite"))
  zipFile <- file.path(src, "ProfoundData.zip")
  oldwd <- setwd(src)
  on.exit(setwd(oldwd), add = TRUE, after = FALSE)
  utils::zip(zipFile, "ProfoundData.sqlite", flags = "-q")
  setwd(oldwd)

  files <- unzipDatabase(zipFile, out)
  expect_equal(files, file.path(out, "ProfoundData.sqlite"))
  expect_equal(file.size(files), file.size(file.path(src, "ProfoundData.sqlite")))

  broken <- file.path(src, "broken.zip")
  writeBin(readBin(zipFile, "raw", n = 50), broken)
  expect_error(unzipDatabase(broken, out), "incomplete or not a zip file")
})

test_that("reportDB() checks the output directory", {
  expect_error(reportDB(outDir = file.path(tempdir(), "doesNotExist")), "Invalid output directory")
})

test_that("reportDB() writes the report outside the package library", {
  skip_on_cran()
  skip_if_not(file.exists(databaseLocation), "PROFOUND_DB does not point to the database")
  skip_if_not_installed("pander")
  skip_if_not(rmarkdown::pandoc_available(), "pandoc not available")
  setDB(databaseLocation)
  rmdDir <- system.file("rmd", package = "ProfoundData")
  before <- list.files(rmdDir, recursive = TRUE)
  out <- tempfile("report")
  dir.create(out)
  on.exit(unlink(out, recursive = TRUE))
  report <- suppressWarnings(suppressMessages(reportDB(outDir = out)))
  expect_true(file.exists(report))
  expect_equal(normalizePath(dirname(report), winslash = "/"), normalizePath(out, winslash = "/"))
  expect_equal(list.files(rmdDir, recursive = TRUE), before)
})
