# Opens a read-only connection to the database registered with setDB(), or to db.
# Read-only, so that a missing file is not replaced by an empty one (#53).
makeConnection <- function(db = dbConnection()$dbname) {
  if (is.na(db)) stop("No PROFOUND database is registered. Please use setDB() with the path to the database (see also downloadDatabase()).", call. = FALSE)
  if (!file.exists(db)) stop("The registered database does not exist (moved or deleted?): ", db, ". Please use setDB() with its current path.", call. = FALSE)
  RSQLite::dbConnect(RSQLite::SQLite(), dbname = db, flags = RSQLite::SQLITE_RO)
}

# Calls f(conn, ...) on a new connection and always closes it (#53),
# e.g. dbCall(RSQLite::dbGetQuery, "SELECT * FROM SITES")
dbCall <- function(f, ..., db = dbConnection()$dbname) {
  conn <- makeConnection(db)
  on.exit(RSQLite::dbDisconnect(conn))
  f(conn, ...)
}

# Checks the arguments of the data functions before any database access (#53).
# Returns period as Date (NA for an open start or end).
checkArgs <- function(dataset = NULL, site = NULL, period = NULL) {
  if (!is.null(dataset) && (!is.character(dataset) || length(dataset) != 1 || is.na(dataset)))
    stop("'dataset' must be a single character string. Please use browseData(\"DATASETS\") to see the available datasets.", call. = FALSE)
  if (!is.null(site) && (length(site) != 1 || is.na(site)))
    stop("'site' must be a single value. Please use browseData(\"SITES\") to see the available sites.", call. = FALSE)
  if (is.null(period)) return(NULL)
  if (inherits(period, "Date")) {
    p <- period
  } else if (is.numeric(period) && length(period) == 2 && anyNA(period)) {
    p <- as.Date(period, origin = "1970-01-01") # c(NA, <Date>) loses the class
  } else {
    p <- as.character(period)
    p <- as.Date(ifelse(grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}$", p), p, NA), format = "%Y-%m-%d")
  }
  if (!length(period) %in% 1:2 || all(is.na(period)) || any(is.na(p) & !is.na(period)))
    stop("Invalid period. Please use \"YYYY-MM-DD\" (start) or c(\"YYYY-MM-DD\", \"YYYY-MM-DD\") (start and end), with NA for an open start or end.", call. = FALSE)
  p
}

# Removes " ", "-" and "+" from a dataset name and replaces the deprecated ENERGYBALANCE
cleanDataset <- function(dataset) {
  dataset <- gsub("[ +-]", "", dataset)
  if (dataset == "ENERGYBALANCE") {
    warning("Dataset 'ENERGYBALANCE' is deprecated.\nPlease use 'ATMOSPHERICHEATCONDUCTION' instead.", call. = FALSE)
    dataset <- "ATMOSPHERICHEATCONDUCTION"
  }
  dataset
}
