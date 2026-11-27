# @title A get version function
# @description  A function to provide information on the version of the DB
# @return a table with the versioning: version name, date and description
# @examples \dontrun{
# versionDB <- getVersion()
# }
# @keywords ProfoundData
# @author Ramiro Silveyra Gonzalez
getVersion <- function(){
  dbCall(RSQLite::dbGetQuery, "SELECT * FROM VERSION")
}
