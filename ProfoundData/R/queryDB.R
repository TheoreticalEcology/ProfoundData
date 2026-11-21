#' @title A function to query the database
#'
#' @description A queryDB function to perform self-defined queries on the PROFOUND database.
#' @param queryItem a character string providing the query
#' @return a data frame with the result of the query.
#' @export
#' @example /inst/examples/queryDBHelp.R
#' @note To report errors in the package or the data, please use the issue tracker
#' in the GitHub repository of ProfoundData \url{https://github.com/TheoreticalEcology/ProfoundData}
queryDB <- function(queryItem) {
  # check the item, check if site is list or
  #run.function <- TRUE
  # now start the function itself
  # make connection
  conn <- makeConnection()
  on.exit(RSQLite::dbDisconnect(conn))
  # build query
  # send the query
  queried <- try(RSQLite::dbGetQuery(conn, queryItem))
  result <- NULL
  if ('try-error' %in% class(queried)) {
    #result[[item]] <- dbGetException(conn) # do something about this
    stop(paste("Error when querying:", queryItem))
  }else if (length(queried[,1]) < 1){
    stop(paste("Error when querying:", queryItem))
  }else{
    result <- queried
  }
  return (result)
}


