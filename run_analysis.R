# Loading Libraries -------------------------------------------------------

library(dplyr)

# loading Data sets ---------------------------------------------------------

# Downloading the dataset and unzipping it in the current working directory.

if (!file.exists("UCI HAR Dataset.zip")) {
    if (!dir.exists("Data")) {
        dir.create("Data")
    }
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileURL, destfile = "Data/UCI HAR Dataset.zip", method = "curl")
    unzip("Data/UCI HAR Dataset.zip", exdir = "Data")
}

# Merging the training and the test sets to create one data set.  ---------

# Reading the data sets

features <- read.table("Data/UCI HAR Dataset/features.txt", col.names = c("n", "functions"))
activities <- read.table("Data/UCI HAR Dataset/activity_labels.txt", col.names = c("code", "activity"))
subject_test <- read.table("Data/UCI HAR Dataset/test/subject_test.txt", col.names = "subjects")
x_test <- read.table("Data/UCI HAR Dataset/test/X_test.txt", col.names = features$functions)
y_test <- read.table("Data/UCI HAR Dataset/test/y_test.txt", col.names = "code")
subject_train <- read.table("Data/UCI HAR Dataset/train/subject_train.txt", col.names = "subjects")
x_train <- read.table("Data/UCI HAR Dataset/train/X_train.txt", col.names = features$functions)
y_train <- read.table("Data/UCI HAR Dataset/train/y_train.txt", col.names = "code")

# Merging the data sets

raw_data <- rbind(x_train, x_test)
raw_labels <- rbind(y_train, y_test)
raw_subjects <- rbind(subject_train, subject_test)
merged_data <- cbind(raw_subjects, raw_labels, raw_data)


# Extracting only the measure on the mean and the standard deviation of each measurements. --------
tidy_data <- merged_data |>
    select(subjects, code, contains("mean"), contains("std"))


# Uses descriptive activity names to name the activities in the data sets. --------

tidy_data$code <- activities[tidy_data$code, 2]

# Appropriately labels the data set with descriptive variable name --------

names(tidy_data)[2] <- "activity"

names(tidy_data) <- gsub("Acc", "Accelerometer", names(tidy_data))
names(tidy_data) <- gsub("Gyro", "Gyroscope", names(tidy_data))
names(tidy_data) <- gsub("Body", "Body", names(tidy_data))
names(tidy_data) <- gsub("gravity", "Gravity", names(tidy_data))
names(tidy_data) <- gsub("Mag", "Magnitude", names(tidy_data))
names(tidy_data) <- gsub("^t", "Time", names(tidy_data))
names(tidy_data) <- gsub("^f", "Frequency", names(tidy_data))
names(tidy_data) <- gsub("-mean()", "Mean", names(tidy_data), ignore.case = TRUE)
names(tidy_data) <- gsub("-std()", "STD", names(tidy_data), ignore.case = TRUE)
names(tidy_data) <- gsub("-freq()", "Frequency", names(tidy_data),
    ignore.case = TRUE
)
names(tidy_data) <- gsub("angle", "Angle", names(tidy_data))


# From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject. -----------------------------------------------------------------------

final_data <- tidy_data |>
    group_by(subjects, activity) |>
    summarise_all(list(mean))
write.table(final_data, "final_data.txt", row.name = FALSE)

# The final data set is written in a text file called "final_data.txt" in the current working directory.
# ---------------------------------------------------------------------------------------------------
