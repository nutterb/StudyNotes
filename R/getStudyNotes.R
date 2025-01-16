getStudyNotes <- function(database_file){
  conn <- dbConnect(RSQLite::SQLite(), 
                    database_file)
  on.exit({ dbDisconnect(conn) })
  
  Notes <- 
    DBI::dbGetQuery(
      conn, 
      "SELECT OID, Note, IsFutureResearch, IsPreparedTalk
       FROM StudyNote
       ORDER BY OID DESC"
    )
  
  Notes$IsFutureResearch <- as.logical(Notes$IsFutureResearch)
  Notes$IsPreparedTalk <- as.logical(Notes$IsPreparedTalk)
  
  Notes
}
