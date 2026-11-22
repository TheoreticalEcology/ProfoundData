#' @title A function report data
#'
#' @description This functions creates a site-by-site report of all available data
#' in the PROFOUND database. The summary is created with a rmarkdown document, which
#' is rendered and saved as a html document.
#' @param outDir a character string indicating an existing output directory in which the
#' html file will be saved. Default is the temporary directory of the R session.
#' @return the path to the html file with the database report (invisibly). In interactive
#' sessions, the report is also opened in the browser.
#' @export
#' @example /inst/examples/reportDBHelp.R
#' @details Please note that creating the report might take several minutes. The report needs
#' the packages rmarkdown, knitr and pander, and pandoc (see \code{\link[rmarkdown]{pandoc_available}}).
#' @note To report errors in the package or the data, please use the issue tracker
#' in the GitHub repository of ProfoundData \url{https://github.com/TheoreticalEcology/ProfoundData}
reportDB <- function(outDir = tempdir()){
  if (!dir.exists(outDir)) stop("Invalid output directory", call. = FALSE)
  for (p in c("rmarkdown", "knitr", "pander")) {
    if (!requireNamespace(p, quietly = TRUE)) stop("reportDB() needs the package ", p, ". Please install it.", call. = FALSE)
  }
  if (!rmarkdown::pandoc_available()) stop("reportDB() needs pandoc, see ?rmarkdown::pandoc_available", call. = FALSE)

  conn <- try(makeConnection(), T)
  if ('try-error' %in% class(conn)){
    stop("Invalid database connection. Please use setDB() to connect to a valid DB", call. = FALSE)
  }
  RSQLite::dbDisconnect(conn)
  # fixes #45 (render a copy in tempdir(), so that no files are written into the package library)
  workDir <- tempfile("reportDB")
  dir.create(workDir)
  on.exit(unlink(workDir, recursive = TRUE))
  rmd <- file.path(workDir, "PROFOUNDsites.Rmd")
  file.copy(system.file("rmd", "PROFOUNDsites.Rmd", package = "ProfoundData"), rmd)
  report <- rmarkdown::render(rmd, params = list(myDB = dbConnection()$dbname), output_dir = outDir,
                              intermediates_dir = workDir, knit_root_dir = workDir, envir = new.env(parent = globalenv()), quiet = TRUE)
  if (interactive()) utils::browseURL(report)
  invisible(report)
}
