# The aim of this test is to check whether it  is possible to download all data

# test whether collapse works

set.seed(1)

library(ProfoundData)


testNoCollapse <- function(tmp){
  expect_type(tmp, "list")
  expect_false(is.data.frame(tmp))
}
testCollapse <- function(tmp){
  expect_s3_class(tmp, "data.frame")
}

test_that("No collapse works", {
  skip_if_not(file.exists(databaseLocation), "PROFOUND_DB does not point to the database")
  skip_on_cran()
  setDB(db_name = databaseLocation)

  datasets <- c("CLIMATE_ISIMIP2A",  "CO2_ISIMIP", "CLIMATE_ISIMIP2B", "CLIMATE_ISIMIP2BLBC",
                "NDEPOSITION_ISIMIP2B","CLIMATE_ISIMIPFT")
  dataset <- sample(datasets, 1)
#    cat("\n");cat(datasets[i]); cat("\n");cat(rep("-", 30), collpase="") ;cat("\n")
  suppressMessages(sites <- browseData(dataset = dataset))
  site <- sample(sites$site, 1)
#    cat(site); cat(", ")
  suppressMessages(tmp <- getData(dataset, site =site, collapse = F))
      #runtests
  testNoCollapse(tmp)

})

test_that("Collapse works", {
  skip_if_not(file.exists(databaseLocation), "PROFOUND_DB does not point to the database")
  skip_on_cran()
  setDB(db_name = databaseLocation)

  datasets <- c("CLIMATE_ISIMIP2A",  "CO2_ISIMIP", #"CLIMATE_ISIMIP2B", #"CLIMATE_ISIMIP2BLBC"
                "NDEPOSITION_ISIMIP2B","CLIMATE_ISIMIPFT")
  dataset <- sample(datasets, 1)
   # cat("\n");cat(datasets[i]); cat("\n");cat(rep("-", 30), collpase="") ;cat("\n")
  suppressMessages(sites <- browseData(dataset = dataset))
  site <- sample(sites$site, 1)
#      cat(site); cat(", ")
  suppressMessages(tmp <- getData(dataset, site =site, collapse = T))
      #runtests
  testCollapse(tmp)
})












