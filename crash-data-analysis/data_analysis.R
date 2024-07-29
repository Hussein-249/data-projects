library(DBI)
library(readr)
library(ggplot2)

# ensures that the script's working directory aligns with the script's location
# change this if your data is stored separately from your script
path <- dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(path)
rm(path)

getwd()
dir()

csv_filename <- "crashdata.csv"

# set to FALSE if your data is stored in a Postgres database
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

random_indices <- sample(nrow(df), 500)

# Subset the dataframe using the random indices
random_df <- df[random_indices, ]

numeric_df = df[sapply(df, is.numeric)]

head(df)

unique(df$collisiontype)

# in progress
# glm(injuries ~ ., data = random_df, family = "binomial")
