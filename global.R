.libPaths("C:/Users/benja/Documents/RLibrary/Standard4.4")
library(shiny)
library(shinyBS)
library(shinybusy)
library(shinydashboard)
library(shinyjs)
library(DT)
library(magrittr)
library(DBI)
library(dplyr)

# library(keyring)
# keyring_create("StudyNotes", "[PASSWORD HERE]")
# key_set_with_value(service = "StudyNotes",
#                    username = "DatabaseFile",
#                    password = "[DATABASE FILE NAME HERE]",
#                    keyring = "StudyNotes")



DATABASE_FILE <- keyring::key_get("StudyNotes", "DatabaseFile", "StudyNotes")

conn <- dbConnect(RSQLite::SQLite(), 
                  DATABASE_FILE)

if (length(dbListTables(conn)) == 0){
  design_code <- readLines("sql/DatabaseDesign.sql") %>% 
    paste0(collapse = "\n") %>% 
    strsplit(";") %>% 
    unlist()
  
  for (dc in design_code){
    result <- DBI::dbSendStatement(conn, dc)
    dbClearResult(result)
  }
  
  data_code <- readLines("sql/PopulateTables.sql") %>% 
    paste0(collapse = "\n") %>% 
    strsplit(";") %>% 
    unlist()
  
  for (dc in data_code){
    result <- DBI::dbSendStatement(conn, dc)
    dbClearResult(result)
  }
}

TOME <- dbReadTable(conn, "Tome")

BOOK <- dbReadTable(conn, "Book")

CHAPTER <- dbReadTable(conn, "Chapter")

VERSE <- dbReadTable(conn, "Verse")

TOPIC <- dbReadTable(conn, "Topic")

dbDisconnect(conn)
