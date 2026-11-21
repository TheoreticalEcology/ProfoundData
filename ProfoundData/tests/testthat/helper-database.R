# Path to a local copy of the PROFOUND database (see downloadDatabase()).
# Tests that need the database are skipped if the environment variable PROFOUND_DB is not set.
databaseLocation <- Sys.getenv("PROFOUND_DB")
