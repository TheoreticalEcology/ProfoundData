#' @title A function to return information of the database connection
#'
#' @description A function to return the filepath to the database.
#' @return a character string with the filepath to the database
#' @author Ramiro Silveyra Gonzalez
#' @seealso \code{\link{setDB}}, \code{\link{downloadDatabase}}  
#' @example /inst/examples/download-set-get-DBHelp.R
#' @export
getDB <- function(){
  conn <- try(makeConnection(), T)
  if ('try-error' %in% class(conn)){
    stop("Invalid database connection. Please use setDB() to connect to a valid DB", call. = FALSE)
  }else{
    RSQLite::dbDisconnect(conn)
  }
  versionHelp()
  #return(getFromNamespace("db",  pos =  "package:ProfoundData")$path)
  return(dbConnection()$dbname)
}

#' @title A function to set the connection to the database
#'
#' @description A setDB function to create a database connection object
#' @param db_name a character string providing the absolute path to the PROFOUND database.
#' @return invisibly, a list with the path to the database (\code{dbname}) and the database driver (\code{driver}) that are now used by the package.
#' @export
#' @seealso \code{\link{getDB}}, \code{\link{downloadDatabase}}  
#' @example /inst/examples/download-set-get-DBHelp.R
#' @note To report errors in the package or the data, please use the issue tracker
#' in the GitHub repository of ProfoundData \url{https://github.com/TheoreticalEcology/ProfoundData}
setDB <- function(db_name = NULL){
  if(is.null(db_name)) db_name <- file.choose()
  
  if (file.exists(db_name)){
    #ProfoundData.env <- new.env()
    #dbConnection() <- list(dbname = "somepath", driver = "somedriver")
    if(grepl("sqlite", db_name)){
      #dbConnection[["driver"]] <- SQLite()
      temp <- RSQLite::SQLite()
    }else{
      stop("Unkown driver")
    }
    #dbConnection[["dbname"]] <- db_name
    #ProfoundData.env$dbConnection <- dbConnection
  }else{
    stop("Please provide a valid path to DB")
  }
  dbConnection(dbname = db_name, driver = temp)
}


dbConnection <- settings::options_manager(dbname=NA, driver=RSQLite::SQLite())


#' Downloads the PROFOUND database 
#' 
#' @description This function downloads the PROFOUND database (version 0.3, doi:10.5880/PIK.2020.006) and unzips it.
#' @details This is a convenience function to download the PROFOUND database. The download is a zip file of 2.8 GB,
#' which contains the database file ProfoundData.sqlite of 8.3 GB; about 11 GB of free disk space are needed while unzipping.
#' The zip file is deleted after the database has been unzipped and checked for completeness (file size). If the download or unzipping fails, please
#' download the database by hand (doi:10.5880/PIK.2020.006). The download may take long; it is
#' allowed to take up to 3 hours, or longer if \code{options("timeout")} is set to a larger value.
#' @param location an existing directory in which the database is stored. If not provided, the function asks in an
#' interactive session whether to use the current working directory, and stops otherwise.
#' @param overwrite if FALSE (default) and the database already exists in \code{location}, the database is not
#' downloaded again, and its path is returned.
#' @return a string with the path to the database file, for use in \code{\link{setDB}}
#' @seealso \code{\link{getDB}}, \code{\link{setDB}}
#' @example /inst/examples/download-set-get-DBHelp.R
#' @export
#' @author Florian Hartig
downloadDatabase <- function(location = NULL, overwrite = FALSE){
  if (is.null(location)) {
    # fixes #45 (CRAN policy: write outside tempdir() only after the user's confirmation)
    if (!interactive() || !isTRUE(utils::askYesNo(paste0("Download the PROFOUND database (2.8 GB; about 11 GB of free disk space are needed while unzipping) into ", getwd(), "?"))))
      stop("Please provide 'location', an existing directory in which to store the database.", call. = FALSE)
    location <- getwd()
  }
  if (!dir.exists(location)) stop("The directory 'location' does not exist: ", location, call. = FALSE)
  sqlFile <- file.path(location, "ProfoundData.sqlite")
  if (file.exists(sqlFile) && !overwrite) {
    message("The database already exists at ", sqlFile, " (use overwrite = TRUE to download it again).")
    return(sqlFile)
  }
  zipFile <- file.path(location, "ProfoundData.zip")
  oldOptions <- options(timeout = max(10800, getOption("timeout")))
  on.exit(options(oldOptions))
  status <- tryCatch(utils::download.file("https://www.pik-potsdam.de/data/doi/10.5880/PIK.2020.006/ProfoundData.zip",
                                          zipFile, mode = "wb"), error = function(e) 1)
  if (status != 0) {
    unlink(zipFile)
    stop("The download failed. Please download the database by hand from https://doi.org/10.5880/PIK.2020.006", call. = FALSE)
  }
  unzipDatabase(zipFile, location)
  unlink(zipFile)
  message("The database is stored at ", sqlFile, "; use setDB() with this path.")
  return(sqlFile)
}

# Unzips the downloaded database and checks the size of the extracted files against the zip index,
# because utils::unzip() may truncate files over 4 GB on some systems. Stops and keeps the zip file if this fails.
unzipDatabase <- function(zipFile, exdir){
  fail <- function(problem) stop(problem, " Please unzip ", zipFile, " by hand, or download the database from https://doi.org/10.5880/PIK.2020.006", call. = FALSE)
  index <- tryCatch(utils::unzip(zipFile, list = TRUE), error = function(e) NULL)
  if (is.null(index) || nrow(index) == 0) fail("The downloaded file is incomplete or not a zip file.")
  utils::unzip(zipFile, exdir = exdir, overwrite = TRUE)
  files <- file.path(exdir, index$Name)
  if (!all(file.exists(files)) || any(file.size(files) != index$Length)) {
    unlink(files)
    fail("Unzipping failed.")
  }
  invisible(files)
}
