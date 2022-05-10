## install/load required packages
if (!require("Require")) {install.packages("Require"); require("Require")}
Require("PredictiveEcology/SpaDES.install")
installSpaDES()
modulePath <- "modules"

## download modules
moduleGitRepos <- c('Biomass_borealDataPrep')
getModule(moduleGitRepos, modulePath = modulePath, overwrite = FALSE)

## packages that are required by modules
makeSureAllPackagesInstalled(modulePath)

## Module documentation -- please go to these pages to read about each module
##  In some cases, there will be important defaults that a user should be aware of
##  or important objects (like studyArea) that may be essential
## browseURL('https://github.com/PredictiveEcology/Biomass_borealDataPrep/blob/main/Biomass_borealDataPrep.rmd')

#devtools::load_all("~/GitHub/reproducible");devtools::load_all("~/GitHub/SpaDES.core") ## See ?simInit for all options

Require(c("reproducible", "SpaDES.core"))

## environment setup -- all the functions below rely on knowing where modules
## are located via this command
setPaths(cachePath = "cache",
         inputPath = "inputs",
         modulePath = modulePath,
         outputPath = "outputs")

## simulation initialization. These may not be appropriate start and end times for one
## or more of the modules, e.g., they may only be defined with calendar dates
simTimes <- list(start = 2011, end = 2011)

googledrive::drive_auth(cache = ".secret", email = "eliotmcintire@gmail.com")
studyArea <- Cache(prepInputs, url = "https://drive.google.com/file/d/1DzVRglqJNvZA8NZZ7XKe3-6Q5f8tlydQ/view?usp=sharing",
                   fun = "raster::shapefile")
species <- Cache(LandR::speciesInStudyArea, studyArea)
# There may be some that are "only genus", as indicated by "Spp" in the name.
#   We should check whether they are relevant for our study area,
#   but we will take the short cut here to just remove them. They are primarily relevant in
#   areas of overlapping, closely related species, which is not the case here for Popu_spp
speciesToUse <- grep("Spp$", species$speciesList, invert = TRUE, value = TRUE)

## Set module parameters -- to see options, look at module documentation
parameters = list(
  Biomass_borealDataPrep  = list(.useCache = c(".inputObjects", "init"),
                                 subsetDataBiomassModel = 50
                                 )
)


## Objects to provide to simInit from e.g., .GlobalEnv,
objects <- list(studyArea = studyArea, studyAreaLarge = studyArea,
                sppNameVector = speciesToUse
#                studyAreaANPP = studyAreaER,
#                sppEquiv = sppEquiv,
#                sppColorVect = sppColorVect
)


## Module inputs to load on a schedule. There may be specific inputs required by modules that are not
## supplied by default
inputs = data.frame()

## Module outputs to save on a schedule. There may be specific outputs required by modules that are not
## supplied by default
outputs = data.frame()

modules <- extractPkgName(moduleGitRepos)

## See ?simInit for all options
mySim <- simInit(
  times = simTimes,
  modules = modules,
  params = parameters,
  inputs = inputs,
  objects = objects,
  outputs = outputs
)

## run the simulation
mySimOut <- spades(mySim, debug = 1) # optionally, use `spades(Copy(mySim))`


