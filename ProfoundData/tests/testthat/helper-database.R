# Path to a local copy of the PROFOUND database (see downloadDatabase()).
# Tests that need the database are skipped if the environment variable PROFOUND_DB is not set.
databaseLocation <- Sys.getenv("PROFOUND_DB")

# Creates a small synthetic database with the structure of the PROFOUND database
# (one site, soro, with two years of daily CLIMATE_LOCAL data; values are made up),
# so that the main functions can be tested without the database (#55).
makeTestDB <- function(file = tempfile(fileext = ".sqlite")) {
  conn <- RSQLite::dbConnect(RSQLite::SQLite(), file)
  on.exit(RSQLite::dbDisconnect(conn))
  sites <- data.frame(site_id = c(21L, 99L), site = c("soro", "global"), lat = c(55.5, NA), lon = c(11.6, NA))
  overview <- data.frame(site_id = 21L, site = "soro", SITES = 1L, CLIMATE_LOCAL = 1L, FLUX = 0L)
  dates <- seq(as.Date("2000-01-01"), as.Date("2001-12-31"), by = "day")
  doy <- as.numeric(format(dates, "%j"))
  climate <- data.frame(record_id = seq_along(dates), site = "soro", site_id = 21L,
                        date = format(dates), day = as.integer(format(dates, "%d")),
                        mo = as.integer(format(dates, "%m")), year = as.integer(format(dates, "%Y")),
                        tmean_degC = round(8 - 8 * cos(2 * pi * doy / 365), 2),
                        p_mm = rep(c(0, 1, 2.5, 0), length.out = length(dates)),
                        tmean_qc = 0, p_qc = 0)
  RSQLite::dbWriteTable(conn, "SITES", sites)
  RSQLite::dbWriteTable(conn, "OVERVIEW", overview)
  RSQLite::dbWriteTable(conn, "OVERVIEW_EXTENDED", overview)
  RSQLite::dbWriteTable(conn, "VERSION", data.frame(record_id = 1L, date = "01-01-2020", version = "0.3", description = "test"))
  RSQLite::dbWriteTable(conn, "TREESPECIES", data.frame(species_id = "fasy", species = "Fagus sylvatica"))
  RSQLite::dbWriteTable(conn, "CLIMATE_LOCAL", climate[0, ])
  RSQLite::dbWriteTable(conn, "CLIMATE_LOCAL_21", climate)
  file
}
