# Tests for the fixes in #54 (aggregated in plotData(), by in summarizeData())

test_that("zooPROFOUND() aggregates by date, month of each year and year", {
  dates <- seq(as.Date("2011-01-01"), as.Date("2012-12-31"), by = "day")
  data <- data.frame(date = dates, year = as.numeric(format(dates, "%Y")), v = seq_along(dates))
  month <- ProfoundData:::zooPROFOUND(data, "month", sum)
  expect_equal(nrow(month), 24)
  expect_s3_class(zoo::index(month), "yearmon")
  expect_equal(as.numeric(month[1, "v"]), sum(1:31))
  expect_equal(as.numeric(month[13, "v"]), sum(data$v[data$date >= as.Date("2012-01-01") & data$date <= as.Date("2012-01-31")]))
  expect_equal(nrow(ProfoundData:::zooPROFOUND(data, "year")), 2)
  expect_equal(nrow(ProfoundData:::zooPROFOUND(data, "date")), length(dates))
  expect_equal(ProfoundData:::zooPROFOUND(data, "day"), ProfoundData:::zooPROFOUND(data, "date"))
  expect_equal(nrow(ProfoundData:::zooPROFOUND(data)), length(dates))
})

test_that("plotPROFOUND.HALFHOURLY() averages each day correctly and without warning", {
  pdf(NULL)
  on.exit(dev.off())
  data <- data.frame(date = rep(as.Date("2011-01-01") + 0:2, each = 48), year = 2011, mo = 1,
                     day = rep(1:3, each = 48), v = rep(c(1, 2, 3), each = 48))
  # the daily means of v are 1, 2, 3; before #54 the mean of the last day was built from the first day
  daily <- ProfoundData:::zooPROFOUND(data, "date", function(x) mean(x, na.rm = TRUE))
  expect_equal(as.numeric(daily[, "v"]), c(1, 2, 3))
  tmp <- list(data = data, dataset = "FLUX", variablesChecked = "v", automaticPanels = TRUE)
  expect_warning(suppressMessages(ProfoundData:::plotPROFOUND.HALFHOURLY(tmp)), NA)
})

test_that("plotData() rejects invalid values of aggregated before querying the database", {
  expect_error(plotData("CLIMATE_LOCAL", site = "soro", aggregated = "week"), "Invalid aggregated value")
  expect_error(plotData("CLIMATE_LOCAL", site = "soro", aggregated = c("day", "month")), "Invalid aggregated value")
})

test_that("plotData() and summarizeData() with the database", {
  skip_if_not(file.exists(databaseLocation), "PROFOUND_DB does not point to the database")
  skip_on_cran()
  setDB(db_name = databaseLocation)
  pdf(NULL)
  on.exit(dev.off())
  expect_warning(suppressMessages(plotData("FLUX", site = "soro", period = c("2011-01-01", "2011-01-31"))), NA)
  for (a in c("date", "day", "month", "year"))
    expect_warning(suppressMessages(plotData("CLIMATE_LOCAL", site = "soro", variables = "tmean_degC",
                                             period = c("2011-01-01", "2012-12-31"), aggregated = a)), NA)
  expect_warning(suppressMessages(plotData("MODIS", site = "soro", aggregated = "date")), NA)
  # the forcing condition historical has no data in 2020; the other conditions are still plotted
  expect_warning(suppressMessages(plotData("CLIMATE_ISIMIP2B", site = "soro", forcingDataset = "GFDLESM2M",
                                           variables = "tmax_degC", period = c("2020-01-01", "2020-12-31"))),
                 "historical: No data to plot", fixed = TRUE)

  expect_error(suppressMessages(summarizeData("TREE", site = "bily_kriz", by = "total")),
               "by = \"total\" is not available for TREE", fixed = TRUE)
  expect_error(suppressMessages(summarizeData("CLIMATE_LOCAL", site = "bily_kriz", by = "day")),
               "by = \"day\" is not available for CLIMATE_LOCAL", fixed = TRUE)
  expect_error(suppressMessages(summarizeData("CLIMATE_ISIMIP2B", site = "soro", forcingDataset = "GFDLESM2M",
                                              forcingCondition = "rcp2p6", by = "day")),
               "by = \"day\" is not available for CLIMATE_ISIMIP2B.", fixed = TRUE)
  expect_equal(nrow(suppressMessages(summarizeData("CLIMATE_LOCAL", site = "bily_kriz", by = "total"))), 1)
  expect_equal(nrow(suppressMessages(summarizeData("TREE", site = "bily_kriz", by = "year"))), 19)
  expect_error(summarizeData("CLIMATE_LOCAL", site = "bily_kriz", by = "week"), "Invalid by value")
})
