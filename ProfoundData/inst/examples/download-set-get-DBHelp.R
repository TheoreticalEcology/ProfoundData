\dontrun{
  
# For downloading the data (2.8 GB) into an existing folder, use
dbfile <- downloadDatabase(location = "path/to/folder")

# Set the connection using the setDB function
setDB(dbfile)

# check if database is available
getDB()
}
