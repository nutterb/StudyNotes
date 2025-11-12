getScripturalReference <- function(study_note_oid){
  conn <- dbConnect(RSQLite::SQLite(), 
                    DATABASE_FILE)
  on.exit({ dbDisconnect(conn) })
  
  dbGetQuery(
    conn, 
    sqlInterpolate(
      conn,
      "SELECT SNSR.OID, SNSR.ParentVerse, 
        B.Abbreviation,
        C.ChapterNumber,
        V.VerseNumber
       FROM [StudyNoteScriptureReference] SNSR
        LEFT JOIN Verse V
          ON SNSR.ParentVerse = V.OID
        LEFT JOIN Chapter C
          ON V.ParentChapter = C.OID
        LEFT JOIN Book B
          ON C.ParentBook = B.OID
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

getStudyTopic <- function(study_note_oid){
  conn <- dbConnect(RSQLite::SQLite(), 
                    DATABASE_FILE)
  on.exit({ dbDisconnect(conn) })
  
  dbGetQuery(
    conn, 
    sqlInterpolate(
      conn,
      "SELECT OID, ParentTopic
       FROM [StudyNoteTopic]
       WHERE ParentStudyNote = ?study_note_oid", 
      study_note_oid = study_note_oid
    )
  )
}
