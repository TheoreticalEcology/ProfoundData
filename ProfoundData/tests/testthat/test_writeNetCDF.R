# Tests for writeSim2netCDF() (#52), no database needed

readGlobal <- function(file, att) {
  nc <- RNetCDF::open.nc(file)
  on.exit(RNetCDF::close.nc(nc))
  RNetCDF::att.get.nc(nc, "NC_GLOBAL", att)
}

test_that("writeSim2netCDF() writes comments, checks input and names files by time range", {
  folder <- file.path(tempdir(), "i52")
  dir.create(folder, showWarnings = FALSE)
  on.exit(unlink(folder, recursive = TRUE))
  df <- data.frame(lon = 30, lat = 20, time = c(2003, 2001, 2002),
                   dbh_total = 1:3, cvegag = c(.1, .2, .3))

  # one comment for all files
  expect_true(writeSim2netCDF(df, comment1 = "my comment", folder = folder))
  f <- list.files(folder, full.names = TRUE)
  expect_length(f, 2)
  expect_true(all(grepl("_2001_2003\\.nc$", f)))
  expect_equal(sapply(f, readGlobal, att = "comment1", USE.NAMES = FALSE), rep("my comment", 2))
  nc <- RNetCDF::open.nc(grep("cvegag", f, value = TRUE))
  expect_equal(RNetCDF::att.get.nc(nc, "cvegag", "units"), "kg m-2")
  RNetCDF::close.nc(nc)
  unlink(f)

  # one comment per variable; tibble-like input (data.frame subclass)
  df2 <- df
  class(df2) <- c("tbl_df", "tbl", "data.frame")
  expect_true(writeSim2netCDF(df2, comment1 = c("a", "b"), folder = folder))
  expect_equal(readGlobal(list.files(folder, "cvegag", full.names = TRUE), "comment1"), "b")
  unlink(list.files(folder, full.names = TRUE))
  # old form: one comment per column of df
  expect_true(writeSim2netCDF(df, comment1 = c("", "", "", "a", "b"), folder = folder))
  expect_equal(readGlobal(list.files(folder, "cvegag", full.names = TRUE), "comment1"), "b")
})

test_that("writeSim2netCDF() rejects invalid input before writing any file", {
  folder <- file.path(tempdir(), "i52invalid")
  dir.create(folder, showWarnings = FALSE)
  on.exit(unlink(folder, recursive = TRUE))
  df <- data.frame(lon = 30, lat = 20, time = 2001:2003, dbh_total = 1:3, cvegag = c(.1, .2, .3))
  expect_message(expect_false(writeSim2netCDF(df, comment1 = c("a", "b", "c"), folder = folder)),
                 "comment1")
  expect_message(expect_false(writeSim2netCDF(df[, 1:3], folder = folder)), "no output variables")
  expect_message(expect_false(writeSim2netCDF(cbind(df[, 1:3], dbh_fasy_x10 = 1), folder = folder)),
                 "dbh_fasy_x10")
  expect_message(expect_false(writeSim2netCDF(cbind(df, foo = 1), folder = folder)), "foo")
  expect_length(list.files(folder), 0)
})

test_that("writeSim2netCDF() leaves out empty comments and removes all files after a failed write", {
  folder <- file.path(tempdir(), "i55netcdf")
  dir.create(folder, showWarnings = FALSE)
  on.exit(unlink(folder, recursive = TRUE))
  df <- data.frame(lon = 30, lat = 20, time = 2001:2003, dbh_total = 1:3, cvegag = c(.1, .2, .3))
  expect_true(writeSim2netCDF(df, comment2 = "b", folder = folder))
  f <- list.files(folder, "cvegag", full.names = TRUE)
  expect_error(readGlobal(f, "comment1"), "not found")
  expect_equal(readGlobal(f, "comment2"), "b")
  unlink(list.files(folder, full.names = TRUE))

  # RNetCDF fails for the character column after the file for dbh_total was written
  df$cvegag <- c("a", "b", "c")
  expect_message(expect_false(writeSim2netCDF(df, folder = folder)), "cvegag")
  expect_length(list.files(folder), 0)
})
