# example requires that a sql DB is registered via setDB(dbfile)
# when run without a registered DB, you will get a file query (depending on OS)

\dontrun{
# writes the report to tempdir() and returns its path
report <- reportDB()
}
