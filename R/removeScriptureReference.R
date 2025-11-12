removeScriptureReference <- function(study_note_oid){
  conn <- dbConnect(RSQLite::SQLite(), 
                    DATABASE_FILE)
  on.exit({ dbDisconnect(conn) })
  
  note_oid <- unique(study_note_oid)
  note_in <- glue::glue_sql("{note_oid*}", 
                             .con = conn)
  
  DBI::dbExecute(
    conn,
    DBI::sqlInterpolate(
      conn,
      "DELETE FROM StudyNoteScriptureReference
       WHERE OID IN (?note_in)",
      note_in = note_in
    )
  ) 
  
}