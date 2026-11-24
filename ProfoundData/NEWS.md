# ProfoundData (development version)

Minor changes

- renamed variable "Jcm2day" to "Jcm2"
- updated DOI and download links to reference to DB version 0.3 
- minor change to plotting TREE variables
- citation("ProfoundData") cites the published data paper (Reyer et al. 2020, Earth System Science Data) (#44)
- links in DESCRIPTION and help pages point to the TheoreticalEcology repository and website (#44)
- tcltk and BayesianTools are no longer dependencies (#44)
- fixes for CRAN check NOTEs (LazyData, help links) and return values added to help pages (#44)
- downloadDatabase() asks before downloading into the working directory (otherwise needs location), skips an existing database (new argument overwrite) and deletes the zip file (#45)
- reportDB() writes to tempdir() by default, returns the path of the report and needs the package pander (#45)
- requires R >= 3.5.0 (#45)
- vignettes rebuilt with database version 0.3: published data paper cited, outdated links updated (also those printed from the database tables); their sources in data-raw/ read the database path from PROFOUND_DB (#47)
- writeSim2netCDF() has no default for folder (was "ISI-MIP" in the working directory); calls without folder now fail (#51)
- getData(), plotData() and summarizeData() report the reason when a query cannot be parsed (e.g. an invalid site) instead of "Could not parse the query" (#51)

Bugfixes 

- corrected flux unit conversion error in summarizeData() (see commit 3dfa079142654780a9bb74da8cca3754bf0c4f26)
- downloadDatabase(): wrong unzip path, 60 s timeout and dependence on an external unzip program (#45)
- plotData() restores par() for TREE and STAND with several species (#51)
- getData() examples: site "le_bray" and the comments on collapse corrected (#51)
- reportDB() wrote intermediate files into the package library (#45)
- summarizeData(dataset = "FLUX", by = "day") returned missing or wrong dates (day and month swapped) (#46)
- writeSim2netCDF() stored the latitude as integer, labelled piab and hawo with wrong species names, wrote the attribute "unit" instead of "units", returned TRUE when no file was written, and warned that the argument large of RNetCDF::create.nc() is deprecated; the example now writes its files (#46)
- browseData(dataset = "DATASETS") also listed the site-specific tables (#46)
- database queries left a connection open; queryDB() now also disconnects after a failed query and gives a clean error message (#46)
- reportDB() used the large plot size for ATMOSPHERICHEATCONDUCTION (#46)
- smaller fixes: "+" is now removed from dataset and species names, plotData() refuses SITEDESCRIPTION, getData() gives "Could not fetch the query" instead of "subscript out of bounds", and the warning about non-existing variables separates them with commas (#46)

# ProfoundData 0.2.1 

small updates and improvement of user-experience

# ProfoundData 0.2.0 

## Modifications to adapt to new ProfoundData database version (v0.2.0) 

## New function(s)

* reportDB to create a site-by-site report of all avalaible data

## New options for existing functions

- summarizeData now also works for the FLUX dataset. 
  
- new option *mode* for summarizeData with two possible values: data and overview.

## Other changes

* Information of the DB connection is no longer stored as a variable in the package environment,
but as an option relying on the [settings R-package](https://cran.r-project.org/package=settings). Thus, there is a new package dependency.

* The package vignette has been restructured and its content distributed into three different documents: profoundData.html, PROFOUNDdatabase.html and PROFOUNDsites.html. The latter must be created by the user with the function reportDB.


# v0.1.6 - Release Notes

## Modifications to adapt to new PROFOUND database version (v0.1.12)

## New function(s)

* New function getDB to return information on the connection to the database

## New options for exisiting function

* New options for plotData/getData to do more specific queries:
    - species
    - quality
    - variables
    - forcingDataset, forcingConditions
    
* SITEDESCRIPTION is accessible through getData, not browseData.


# v0.1.5 - Release Notes

## Modifications to adapt to new ProfoundData database version (v0.1.11) 

## New function(s)

* summarizeData to summarize climatic datasets and TREE data
* queryDB to pass self-defined queries to the database
* New options for browseData to access
  - data policy
  - data source
  - sites description
  
# v0.1.3 - Release Notes

## Modifications to adapt to new ProfoundData database version (v0.1.9) 

## New options for exisiting functions

* New options for plotData and more datasets
* browseData integrates previous getFunctions and allows, besides previous options, to access VERSION and METADATA
* New option in getData to download the SITES


# v0.1.2 - Release Notes

## Minor modifications

* Corrected small bugs and typos.

* Format options for new datasets in the DB.

# v0.1.1 - Release Notes

## First package release



