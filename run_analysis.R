## Step 0 - load packages and download and uzip data

packages <- c("data.table", "reshape2")
sapply(packages, require, character.only=TRUE, quietly=TRUE)

url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
filename <- "dataset.zip"
f <- file.path(getwd(), filename)

if (!file.exists(filename)) {
  download.file(url, filename)
}

if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename)
}

# Step 1 - Merge the training and test sets to create one data set

train_data <- read.table("UCI HAR Dataset/train/X_train.txt")
train_labels <- read.table("UCI HAR Dataset/train/Y_train.txt")
train_subjects <- read.table("UCI HAR Dataset/train/subject_train.txt")

test_data <- read.table("UCI HAR Dataset/test/X_test.txt")
test_labels <- read.table("UCI HAR Dataset/test/Y_test.txt")
test_subjects <- read.table("UCI HAR Dataset/test/subject_test.txt")

data <- rbind(train_data, test_data)
labels <- rbind(train_labels, test_labels)
subjects <- rbind(train_subjects, test_subjects)


# Step 2 - Extract only the measurements on the mean and standard deviation for each measurement

## loading the features
features <- read.table("UCI HAR Dataset/features.txt")
features[, 2] <- as.character(features[, 2])

## extracting only wanted features - mean and std
selected_index <- grep(".*mean.*|.*std.*", features[, 2])
data <- data[, selected_index]


# Step 3 - Use descriptive activity names to name the activities in the data set

## loading the activity lables
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")
activity_labels[, 2] <- as.character(activity_labels[,2])

## replacing the labels
labels[, 1] <- activity_labels[labels[, 1], 2]

# Step 4 - Appropriately label the data set with descriptive variable names

## renaming the default names from features.txt
selected_names <- features[selected_index,2]
selected_names = gsub('-mean', 'Mean', selected_names)
selected_names = gsub('-std', 'Std', selected_names)
selected_names <- gsub('[-()]', '', selected_names)

## merge datasets
all <- cbind(subjects, labels, data)

## rename columns
colnames(all) <- c("subject", "activity", selected_names)


# Step 5 - Create a second, independent tidy data set with the average of each variable for each activity and each subject

##prepare final dataset
all_melted <- melt(all, id = c("subject", "activity"))
all_mean <- dcast(all_melted, subject + activity ~ variable, mean)

## export data set to file
write.table(all_mean, "tidy_data.txt", row.names = FALSE, quote = FALSE)
