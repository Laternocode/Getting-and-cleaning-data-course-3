##ASSIGMENT 1

##load needed librarys
library(dplyr)
library(plyr)
library(data.table)
library(tidyr)

##set the right working directory
setwd("C:/Users/Gert-Jan/Documents/Datascience/Course 3 Getting and Cleaning Data")

## create "data" directory if needed
if(!file.exists("data")){
  dir.create("data")
}

##download file
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")

###Unzip DataSet to /data directory
unzip(zipfile="./data/Dataset.zip",exdir="./data")


##read data files
dataTest <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
dataTrain <- read.table("./data/UCI HAR Dataset/train/X_train.txt")

dataTestActivity <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
dataTrainActivity <- read.table("./data/UCI HAR Dataset/train/y_train.txt")

dataTestSubject <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")
dataTrainSubject <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")

dataFeatures <- read.table("./data/UCI HAR Dataset/features.txt")

##merge subject data and rename variable "subject"
totalDataSubject <- rbind(dataTrainSubject, dataTestSubject)
setnames(totalDataSubject, "V1", "subject")

##merge activity data and rename variable "activity"
totalDataActivity <- rbind(dataTrainActivity, dataTestActivity)
setnames(totalDataActivity, "V1", "activity")

##merge training and test data and rename variables according to dataFeatures
dt <- rbind(dataTrain, dataTest)
colnames(dt) <- dataFeatures$V2

##merge dt, totalDataSubject, totalDataActivity
dt <- cbind(totalDataSubject, totalDataActivity, dt)

##ASSIGMENT 2
##Extract only de measurements on the mean and standard deviation for each measurement

subdataFeaturers <- dataFeatures$V2[grep("mean\\(\\)|std\\(\\)", dataFeatures$V2)]
SelectedNames <- c("subject", "activity", as.character(subdataFeaturers))
dt <- subset(dt, select = SelectedNames)

##ASSIGMENT 3
#read labels from file
dataLabels <- read.table("./data/UCI HAR Dataset/activity_labels.txt")
dataLabels$V2 <- sub("_", "", dataLabels$V2)
dataLabels$V2 <- tolower(dataLabels$V2)
dt$activity <- as.character(dt$activity)
dt$activity <- dataLabels[dt$activity, 2]

##ASSIGMENT 4
## Appropriatlely labels the data set with descriptive variable names

names(dt) <- gsub("^t", "time", names(dt))
names(dt) <- gsub("^f", "frequency", names(dt))
names(dt) <- gsub("Acc", "Accelerometer", names(dt))
names(dt) <- gsub("Gyro", "Gyroscope", names(dt))
names(dt) <- gsub("Mag", "Magnitude", names(dt))
names(dt) <- gsub("BodyBody", "Body", names(dt))

##Assigment 5
## From the data set in step 4, creates a scond , independent tidy dataset with the avarage of each 
## variable for each activity an each subject.

dtTemp <-aggregate(. ~subject + activity, dt, mean)
dtTemp <-dtTemp[order(dtTemp$subject,dtTemp$activity),]
write.table(dtTemp, file = "tidydata.txt",row.name=FALSE)