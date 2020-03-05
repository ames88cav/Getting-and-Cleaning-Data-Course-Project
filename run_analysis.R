#Download data set from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
#Extract zip into the working directory file
#Set working directory 
setwd("/Users/jackmercier/Rstudio files")

if (!require("data.table")) {
  install.packages("data.table")
}

if (!require("reshape2")) {
  install.packages("reshape2")
}

require("data.table")
require("reshape2")

#Import dataset into R
dataset <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]

#Import column names
columnnames <- read.table ("./UCI HAR Dataset/features.txt")[,2]

#Extracts only the measurements on the mean and standard deviation for each measurement.
extractcolumnnames <- grepl("mean|std", columnnames)

#Imports xtest and ytest datasets.
xtest <- read.table("./UCI HAR Dataset/test/X_test.txt")
ytest <- read.table("./UCI HAR Dataset/test/y_test.txt")
subjecttest <- read.table("./UCI HAR Dataset/test/subject_test.txt")

names(xtest) = columnnames

# Extract only the measurements on the mean and standard deviation for each measurement.
xtest = xtest[,extractcolumnnames]

# Import dataset
ytest[,2] = dataset[ytest[,1]]
names(ytest) = c("Dataset_ID", "datasetlabel")
names(subjecttest) = "subject"

# Bind data
testdata <- cbind(as.data.table(subjecttest), ytest, xtest)

#  import xtrain and ytrain dataset.
xtrain <- read.table("./UCI HAR Dataset/train/X_train.txt")
ytrain <- read.table("./UCI HAR Dataset/train/y_train.txt")

subjecttrain <- read.table("./UCI HAR Dataset/train/subject_train.txt")

names(xtrain) = columnnames

# Extract only the measurements on the mean and standard deviation for each measurement.
xtrain = xtrain[,extractcolumnnames]

# Import activity data
ytrain[,2] = dataset[ytrain[,1]]
names(ytrain) = c("Dataset_ID", "datasetlabel")
names(subjecttrain) = "subject"


# Bind data
bindeddata <- cbind(as.data.table(subjecttrain), ytrain, xtrain)


# Merge test and train bindeddata
data = rbind(testdata, bindeddata)

id_labels   = c("subject", "Dataset_ID", "datasetlabel")
data_labels = setdiff(colnames(data), id_labels)
melt_data      = melt(data, id = id_labels, measure.vars = data_labels)

# Perfom mean to dataset using dcast function
processed_data  = dcast(melt_data, subject + datasetlabel ~ variable, mean)

write.table(processed_data, file = "./processed_data.txt")
