# The purpose of this R script is to convert datasets used
#     in ENVH 556 to Rdatasets
#     Winter 2019
#TODO:  verify the datasets I'm using are the correct ones and
#       that we have all the variables we want,
#       coded as we want
#
## Setting up for 2019
# First save current path and use the foreign package
(setupPath <- getwd())
library(foreign)

# Path for datasets to convert
(convertpath <-
        file.path(setupPath, "Datasets", "DatasetsForConversion"))

# Datasets path for converted datasets
(datapath<-file.path(setupPath,"Datasets"))

#-----------------------------
# DEMS data:
## Read data from Stata into R
DEMSCombinedPersonal <-
    read.dta(file.path(convertpath, "CombinedPersonalRev2.dta"))

## Save into an Rdataset
saveRDS(DEMSCombinedPersonal,
        file = file.path(datapath, "DEMSCombinedPersonal.rds"))

## verifying it all works
#rm(DEMSCombinedPersonal)
#DEMS2 <- readRDS(file=file.path(datapath,"DEMSCombinedPersonal.rds"))

#----------------------
# Snapshot data
## Read data from Stata into R
## See below for edits to allseasons data for the students
 
# Read the data
allseasons <-
    read.dta(file.path(convertpath, "allseasons_ENVH556.dta"))
fall <- read.dta(file.path(convertpath, "fall2006.dta"))
summer <- read.dta(file.path(convertpath, "summer2006.dta"))
winter <- read.dta(file.path(convertpath, "winter2007.dta"))

# Save into an Rdataset
saveRDS(allseasons,file=file.path(datapath,"allseasons.rds"))
saveRDS(fall,file=file.path(datapath,"fall.rds"))
saveRDS(summer,file=file.path(datapath,"summer.rds"))
saveRDS(winter,file=file.path(datapath,"winter.rds"))

## Update the allseasons data to change a few variable names, drop yhat, and
## recode season to match seasonfac
### Var name changes:  seasonnum -> seasonfac
###                    whichdata -> season
# First read in the allseasons data                    
allseasonsR<-readRDS(file=file.path(convertpath,"allseasons.rds"))

# drops yhat
allseasonsR<-allseasonsR[,c(1:79)]

# renames whichdata
names(allseasonsR)[78]<-"season" 

# recodes season to have same numeric value as seasonfac
allseasonsR$season <- allseasonsR$season+1

# renames seasonnum
names(allseasonsR)[79]<-"seasonfac" 

# save the dataset as an R dataset
saveRDS(allseasonsR,file=file.path(datapath,"allseasonsR.rds"))

#-------------------------------------
# Welder data
## Read data from Stata into R
# Note:  this is the OLD version that has some negative values for particulate
# and should not be used: weld school exp 556.dta
weldschool <-
    read.dta(file.path(datapath, "weldschoolexpo.dta"))

## Save into an Rdataset
saveRDS(weldschool,file=file.path(datapath,"weldschool.rds"))

#----------------------------------
# DEMS Term project data
## Read data from Stata into R
RECpersonal<-read.dta(file.path(convertpath,"recjob7feb.dta"))
cohist<-read.dta(file.path(convertpath,"cohist15feb.dta"))
jem<-read.dta(file.path(convertpath,"jem7feb.dta"))

## rename the variable for adj hp 1990+

cohist <- rename(cohist, ln_adj_hp1990 = lnhp2)

## Save into an Rdataset
saveRDS(RECpersonal,file=file.path(datapath,"RECpersonal.rds"))
saveRDS(cohist,file=file.path(datapath,"cohist.rds"))
saveRDS(jem,file=file.path(datapath,"jem.rds"))

