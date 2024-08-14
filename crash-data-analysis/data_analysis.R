library(DBI) # Database Interface
library(readr) # Read Rectangular Text Data
library(ggplot2) # Grammar of Graphics

# ensures that the script's working directory aligns with the script's location
# change this if your data is stored separately from your script
path <- dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(path)
rm(path)

# check to ensure that the wd is correct
getwd()
dir()

###   Part 1 - Data Load and Model ###

csv_filename <- "crashdata.csv"

# set to FALSE if your data is stored in a Postgres database, then replace auth
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

random_indices <- sample(nrow(df), 750)

# Subset the dataframe using the random indices
random_df <- df[random_indices, ]

head(random_df)

# unique(df$injuries)

###   Part 2 - Analyzing Distributions ###

with(random_df, {
  
  # pdf("Injuries-QQ-Plot.pdf", title = "Injuries QQ Plot Title")
  
  true_injuries <- vehicleaestspeed_kmh[injuries == TRUE]
  false_injuries <- vehicleaestspeed_kmh[injuries == FALSE]
  
  par(mfrow = c(1, 2))
  qqnorm(false_injuries, main = "Q-Q No Injuries")
  qqline(false_injuries, col = "green")
  
  qqnorm(true_injuries, main = "Q-Q Injuries")
  qqline(true_injuries, col = "red")
  
  # dev.off()
  
  true_shapiro_test <- shapiro.test(true_injuries)
  print(true_shapiro_test)
  
  true_shapiro_test <- shapiro.test(false_injuries)
  print(true_shapiro_test)
  
  summary(true_injuries)
  summary(false_injuries)
  
  # reset the output to single plot per image
  par(mfrow = c(1, 1))
  
  boxplot(true_injuries, false_injuries, main = "Boxplot of speed based on injuries")
  
  t_test_result <- t.test(true_injuries, false_injuries)
  
  print(t_test_result)
})

###   Part 3 - Chi Squared Test ### 

with(random_df, { 
  
})

###   Part 4 - PCA  ### 

with(random_df, { 
  
  df <- subset(df, select = c(vehicleadriverage,
                              vehiclebdriverage,
                              surfacecoefficient_percent,
                              vehicleaestspeed_kmh,
                              vehiclebestspeed_kmh,
                              vehicleabrakedist_m))
  
  random_indices <- sample(nrow(df), 50)
  
  # Subset the dataframe using the random indices
  random_df <- df[random_indices, ]
  
  numeric_df <- random_df[sapply(random_df, is.numeric)]
  
  scaled_df <- scale(numeric_df)
  
  PCA_result <- prcomp(scaled_df, center = TRUE, scale. = TRUE)
  
  biplot(PCA_result)
  summary(PCA_result) 

  })
