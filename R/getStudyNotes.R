getStudyNotes <- function(database_file){
  conn <- dbConnect(RSQLite::SQLite(), 
                    database_file)
  on.exit({ dbDisconnect(conn) })
  
  DBI::dbGetQuery(
    conn, 
    "SELECT OID, Note 
     FROM StudyNote
     ORDER BY OID DESC"
  )
}
