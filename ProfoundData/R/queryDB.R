#' @title A function to query the database
#'
#' @description A queryDB function to perform self-defined queries on the PROFOUND database.
#' @param queryItem a character string providing the query
#' @return a data frame with the result of the query (with zero rows and a message if the query returns no rows).
#' @export
#' @example /inst/examples/queryDBHelp.R
#' @note To report errors in the package or the data, please use the issue tracker
#' in the GitHub repository of ProfoundData \url{https://github.com/TheoreticalEcology/ProfoundData}
queryDB <- function(queryItem) {
  queried <- try(dbCall(RSQLite::dbGetQuery, queryItem), silent = TRUE)
  if ('try-error' %in% class(queried)) {
    stop(paste0("Error when querying: ", queryItem, " (", conditionMessage(attr(queried, "condition")), ")"))
  }
  if (nrow(queried) < 1) message("The query returned no rows: ", queryItem)
  return(queried)
}


