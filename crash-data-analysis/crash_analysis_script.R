library(DBI) # Database Interface
library(readr) # Read Rectangular Text Data
library(ggplot2) # Grammar of Graphics
library(vcd) # for mosaic plot
library(RColorBrewer) # colours for nicer plots

# ensures that the script's working directory aligns with the script's location
# change this if your data is stored separately from your script
path <- dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(path)
rm(path)

# check to ensure that the working directory is correct
getwd()
dir()

###   Part 1 - Data Load and Descriptive Statistics ###

csv_filename <- "crashdata.csv"

# set to FALSE if your data is stored in a PostGres database, then replace auth
use_csv <- TRUE

if (use_csv) {
  
  #  read.csv() returns a dataframe, so no need to convert it
  df <- read.csv(csv_filename)
  
} else {
  
  # replace with your auth for now
  your_database <- "your_database"
  username <- "your_username"
  pass <- "your_password"
  
  con <- dbConnect(RPostgres::Postgres(), dbname = your_database, user = username, password = pass)
  
  # based on provided DDL.sql
  table_name <- "IncidentData"
  
  # Read all values from the PostgreSQL table, ordered by increasing date
  query <- paste("SELECT * FROM", table_name, "ORDER BY incidentdate asc")
  df <- dbGetQuery(con, query)
  
  # Close the database connection
  dbDisconnect(con)
  rm(table_name)
  rm(con)
  
  # uncomment in case you want to switch to a .csv file to bypass connecting to the database
  # write_csv(df, csv_filename)
}

df <- subset(df, select = -incidentid)

random_indices <- sample(nrow(df), 1000)

# Subset the dataframe using the random indices
df_sample <- df[random_indices, ]

head(df_sample)

# unique(df$injuries)

###   Part 2 - Analyzing Distributions ###

# Summary: Analyzing the distributions of incidents with and without injuries to find

with(df_sample, {
  
  # uncomment to save plots to a PDF. 
  # If you intend to run the script multiple times you can leave this commented.
  # pdf("Injuries-QQ-Plot.pdf", title = "Injuries QQ Plot Title")
  
  true_injuries <- vehicleaestspeed_kmh[injuries == TRUE]
  false_injuries <- vehicleaestspeed_kmh[injuries == FALSE]
  
  par(mfrow = c(1, 2))
  qqnorm(false_injuries, main = "Q-Q No Injuries")
  qqline(false_injuries, col = "green")
  
  qqnorm(true_injuries, main = "Q-Q Injuries")
  qqline(true_injuries, col = "red")
  
  # comment / uncomment to open and close the PDF handled by the comment above
  # dev.off()
  
  true_shapiro_test <- shapiro.test(true_injuries)
  print(true_shapiro_test)
  
  false_shapiro_test <- shapiro.test(false_injuries)
  print(false_shapiro_test)
  
  summary(true_injuries)
  summary(false_injuries)
  
  # reset the output to single plot per image
  par(mfrow = c(1, 1))
  
  boxplot(true_injuries, false_injuries, main = "Boxplot of speed based on injuries")
  
  t_test_result <- t.test(true_injuries, false_injuries)
  
  print(t_test_result)
})

###   Part 3 - Chi Squared Test ### 

random_chi_indices <- sample(nrow(df), 500)

df_chi_sample <- df[random_chi_indices, ]

with(df_chi_sample, { 
  # prepare contingency tables for categorical variables of interest
  
  weather_contingency_table <- table(weathercondition, injuries)
  road_contingency_table <- table(roadcondition, injuries)
  surface_contingency_table <- table(surfacecoefficient_percent, injuries)
  collision_contingency_table <- table(collisiontype, injuries)
  
  print(weather_contingency_table)
  print(collision_contingency_table)
  
  # SAMPLE NOT FINAL
  barplot(collision_contingency_table, beside = TRUE, legend = TRUE,
          col = c("cadetblue", "aquamarine"),
          main = "Grouped Bar Plot of Injuries by Collision Type",
          xlab = "Preference", ylab = "Count")
  
  weather_chi_test <- chisq.test(weather_contingency_table)
  road_chi_test <- chisq.test(road_contingency_table)
  surface_chi_test <- chisq.test(surface_contingency_table)
  collision_chi_test <- chisq.test(collision_contingency_table)
  
  print(weather_chi_test)
  print(collision_chi_test)
})

###   Part 4 - PCA  ### 

# SAMPLE NOT FINAL

with(df_sample, { 
  
  df <- subset(df, select = c(vehicleadriverage,
                              vehiclebdriverage,
                              surfacecoefficient_percent,
                              vehicleaestspeed_kmh,
                              vehiclebestspeed_kmh,
                              vehicleabrakedist_m))
  
  random_indices <- sample(nrow(df), 50)
  
  # Subset the dataframe using the random indices
  df_sample <- df[random_indices, ]
  
  numeric_df <- df_sample[sapply(df_sample, is.numeric)]
  
  scaled_df <- scale(numeric_df)
  
  PCA_result <- prcomp(scaled_df, center = TRUE, scale. = TRUE)
  
  biplot(PCA_result)
  summary(PCA_result) 

  })
