saveNote <- function(note, 
                     is_future_research = FALSE, 
                     is_prepared_talk = FALSE,
                     study_note_oid = numeric(0), 
                     verse_oid = numeric(0), 
                     other_reference = character(0), 
                     topic_oid = numeric(0)){
  conn <- dbConnect(RSQLite::SQLite(), 
                    DATABASE_FILE)
  on.exit({ dbDisconnect(conn) })

  other_reference <- other_reference[trimws(other_reference) != ""]
  note <- trimws(note)
  
  # Add or edit the note --------------------------------------------
  if (length(study_note_oid) == 0){
    statement <- "INSERT INTO StudyNote (Note, IsFutureResearch, IsPreparedTalk) VALUES (?note, ?future_research, ?prepared_talk)"
    result <- 
      dbSendStatement(
        conn, 
        sqlInterpolate(
          conn, 
          statement, 
          note = note, 
          future_research = is_future_research, 
          prepared_talk = is_prepared_talk
        )
      )
    DBI::dbClearResult(result)
    result <- DBI::dbSendStatement(conn, 
                                   "SELECT last_insert_rowid() AS OID")
    NewID <- DBI::dbFetch(result)
    dbClearResult(result)
    study_note_oid <- NewID$OID
  } else {
    statement <- "UPDATE StudyNote SET Note = ?note,
    IsFutureResearch = ?future_research, 
    IsPreparedTalk = ?prepared_talk
    WHERE OID = ?study_note_oid"
    result <- 
      dbSendStatement(
        conn, 
        sqlInterpolate(
          conn, 
          statement, 
          note = note, 
          future_research = is_future_research, 
          prepared_talk = is_prepared_talk,
          study_note_oid = study_note_oid
        )
      )
    DBI::dbClearResult(result)
  }
  
  # Add additional scriptural reference -----------------------------
  ExistingVerse <- 
    dbGetQuery(
      conn, 
      sqlInterpolate(
        conn,
        "SELECT ParentVerse 
          FROM StudyNoteScriptureReference 
         WHERE ParentStudyNote = ?study_note_oid", 
        study_note_oid = study_note_oid
      )
    )
  
  verse_oid <- verse_oid[!verse_oid %in% ExistingVerse$ParentVerse]
  
  for (v in verse_oid){
    statement <- "INSERT INTO StudyNoteScriptureReference 
                  (ParentStudyNote, ParentVerse)
                  VALUES
                  (?study_note_oid, ?verse_oid)"
    res <- 
      dbSendStatement(
        conn, 
        sqlInterpolate(
          conn, 
          statement, 
          study_note_oid = study_note_oid, 
          verse_oid = v
        )
      )
    dbClearResult(res)
  }
  
  # Add Other Reference ---------------------------------------------
  
  if (length(other_reference) > 0){
    statement <- "INSERT INTO StudyNoteOtherReference
                 (ParentStudyNote, Reference)
                 VALUES
                 (?study_note_oid, ?reference)"
    for (ref in other_reference){
      res <- 
        dbSendStatement(
          conn, 
          sqlInterpolate(
            conn,
            statement, 
            study_note_oid = study_note_oid, 
            reference = ref
          )
        )
      dbClearResult(res)
    }
  }
  
  # Add Study Note Topics -------------------------------------------
  
  ExistingTopic <- 
    dbGetQuery(
      conn, 
      sqlInterpolate(
        conn,
        "SELECT ParentTopic 
          FROM StudyNoteTopic 
         WHERE ParentStudyNote = ?study_note_oid", 
        study_note_oid = study_note_oid
      )
    )
  
  topic_oid <- topic_oid[!topic_oid %in% ExistingTopic$ParentTopic]

  for (t in topic_oid){
    statement <- "INSERT INTO StudyNoteTopic
                  (ParentStudyNote, ParentTopic)
                  VALUES
                  (?study_note_oid, ?topic_oid)"
    res <- 
      dbSendStatement(
        conn, 
        sqlInterpolate(
          conn, 
          statement, 
          study_note_oid = study_note_oid, 
          topic_oid = t
        )
      )
    dbClearResult(res)
  }
}
