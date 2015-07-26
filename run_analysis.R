# 1. Merges the training and the test sets to create one data set.
x_train <- read.table("UCI HAR Dataset/train/X_train.txt")
x_test <- read.table("UCI HAR Dataset/test/X_test.txt")
y_train <- read.table("UCI HAR Dataset/train/y_train.txt")
y_test <- read.table("UCI HAR Dataset/test/y_test.txt")
subj_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
subj_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
x_combined <- rbind(x_train, x_test)
y_combined <- rbind(y_train, y_test)
subj_combined <- rbind(subj_train, subj_test)

# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
x_names <- read.table("UCI HAR Dataset/features.txt")
mean_std_columns <- grep("-mean[(][)]|-std[(][)]", x_names[, 2])
x_combined <- x_combined[, mean_std_columns]
names(x_combined) <- x_names[mean_std_columns, 2]
names(x_combined) <- gsub("[(]|[)]", "", names(x_combined))
names(x_combined) <- tolower(names(x_combined))

# 3. Uses descriptive activity names to name the activities in the data set.
activity <- read.table("UCI HAR Dataset/activity_labels.txt")
activity[, 2] = gsub("_", "", tolower(as.character(activity[, 2])))
y_combined[,1] = activity[y_combined[,1], 2]
names(y_combined) <- "activity"

# 4. Appropriately labels the data set with descriptive variable names.
names(subj_combined) <- "subject"
combined_data <- cbind(subj_combined, y_combined, x_combined)

# 5. From the data set in Step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
unique_subj = unique(subj_combined)[,1]
subj_count = length(unique_subj)
activity_count = length(activity[,1])
numCols = dim(combined)[2]
data_avg = combined_data[1:(subj_count*activity_count), ]

row = 1
for (s in 1:subj_count) {
        for (a in 1:activity_count) {
                data_avg[row, 1] = unique_subj[s]
                data_avg[row, 2] = activity[a, 2]
                tmp <- combined_data[combined_data$subject==s & combined_data$activity==activity[a, 2], ]
                data_avg[row, 3:numCols] <- colMeans(tmp[, 3:numCols])
                row = row+1
        }
}

write.table(data_avg, "tidy_data_with_averages.txt", row.names = FALSE)