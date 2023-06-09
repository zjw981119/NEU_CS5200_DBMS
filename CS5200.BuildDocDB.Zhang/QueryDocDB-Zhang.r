### Query Document Database
###
### Author: Zhang, Jinwei
### Course: CS5200
### Term: 2023 Spring

# assumes that you have set up the database structure by running CreateFStruct.R

# Query Parameters (normally done via a user interface)

quarter <- "Q2"
year <- "2021"
customer <- "Medix"
# customer <- "CarrePoint"

# write code below CarrePoint

# get current work directory
wd <- getwd()
wd

# -------------------------------------------------------------------
# create lock file if it doesn't exist, or return error code if it exists
setLock <- function(customer, year, quarter){
  lockFile = paste(wd, "docDB", "reports", year, quarter, customer, ".lock", sep = "/")
  # file doesn't exist
  if(!file.exists(lockFile)){
    file.create(lockFile)
    return(0)
  } else {
    # file already exist, return error code(-1)
    return(-1)
  }
}

# test setLock
setLock(customer, year, quarter)
# -------------------------------------------------------------------


# -------------------------------------------------------------------
# return the generated report name following the Customer.Year.Quarter.pdf pattern
genReportFName <- function(customer, year, quarter){
  pdfFileName = paste(customer, year, quarter, "pdf", sep = ".")
  return(pdfFileName)
}

# test genReportFName
pdfFileName = genReportFName(customer, year, quarter)
pdfFileName
# -------------------------------------------------------------------


# -------------------------------------------------------------------
# check if there exists a lock file in the folder. If not, copy the downloaded pdf to that folder
storeReport <- function(customer, year, quarter){
  # generate report name
  pdfFileName = genReportFName(customer, year, quarter)
  # print("pdfFileName")
  # print(pdfFileName)
  # lock file name/path
  lockFile = paste(wd, "docDB", "reports", year, quarter, customer, ".lock", sep = "/")
  # print("lockFile")
  # print(lockFile)
  folderName = paste(wd, "docDB", "reports", year, quarter, customer, sep = "/")
  # print("folderName")
  # print(folderName)
  # check lock file
  if(!file.exists(lockFile)){
    file.copy(from = paste(".", pdfFileName, sep = "/"), to = folderName, overwrite = TRUE)
  }
}

# test storeReport, if no lock file, copy and return true
storeReport(customer, year, quarter)
# -------------------------------------------------------------------


# -------------------------------------------------------------------
# remove the lock file
relLock <- function(customer, year, quarter){
  lockFile = paste(wd, "docDB", "reports", year, quarter, customer, ".lock", sep = "/")
  if(file.exists(lockFile)){
    file.remove(lockFile)
  }
}

# test relLock
relLock(customer, year, quarter)

