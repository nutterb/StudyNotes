getScripturalReference <- function(study_note_oid){
  conn <- dbConnect(RSQLite::SQLite(), 
                    DATABASE_FILE)
  on.exit({ dbDisconnect(conn) })
  
  dbGetQuery(
    conn, 
    sqlInterpolate(
      conn,
      "SELECT OID, ParentVerse
       FROM [StudyNoteScriptureReference]
       WHERE ParentStudyNote = ?study_note_oid", 
      study_note_oid = study_note_oid
    )
  )
}

getOtherReference <- function(study_note_oid){
  conn <- dbConnect(RSQLite::SQLite(), 
                    DATABASE_FILE)
  on.exit({ dbDisconnect(conn) })
  
  dbGetQuery(
    conn, 
    sqlInterpolate(
      conn,
      "SELECT OID, Reference
       FROM [StudyNoteOtherReference]
       WHERE ParentStudyNote = ?study_note_oid", 
      study_note_oid = study_note_oid
    )
  )
}

