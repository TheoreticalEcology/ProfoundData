# The Profound dataset for checking and benchmarking of dynamic vegetation models

The PROFOUND database is a collection of data for calibrating, validating and benchmarking dynamic vegetation models, created by [Cost Action FP1304 PROFOUND](https://twitter.com/FP1304Profound). The database itself, including documentation and description of the data, is hosted by the Potsdam Institute for Climate Impact Research [https://doi.org/10.5880/PIK.2020.006](https://doi.org/10.5880/PIK.2020.006). You can download the database either there, or, via the R package (see below). The source code that was used to create the database is available [here](https://github.com/TheoreticalEcology/ProfoundData/tree/master/PROFOUND%20database).   

## Installing the ProfoundData R package

The ProfoundData R package helps users to download and explore the PROFOUND database from the R environment. The package is available from CRAN. To install the (typically more stable) CRAN version, just type:

```{r}
install.packages("ProfoundData")
```

If you want to install the current (development) version from this repository, run

```{r}
devtools::install_github(repo = "TheoreticalEcology/ProfoundData", 
subdir = "ProfoundData", 
dependencies = T, build_vignettes = T)
```
Status of the automatic `R CMD check` (GitHub Actions) on the master branch:

[![R-CMD-check](https://github.com/TheoreticalEcology/ProfoundData/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/TheoreticalEcology/ProfoundData/actions/workflows/R-CMD-check.yaml)


## First steps

To get an overview about its functionality once the package is installed, run

```{r}
library(ProfoundData)
?ProfoundData
vignette("ProfoundData", package="ProfoundData")
```
To cite the package, run 

```{r}
citation("ProfoundData")
```

## Downloading the database from R

The database is a 2.8 GB download (8.3 GB unzipped). Store it in an existing folder and register it with setDB():

```{r}
dbfile <- downloadDatabase(location = "path/to/folder")
setDB(dbfile)
```

