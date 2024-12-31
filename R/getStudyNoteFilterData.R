getStudyNoteFilterData <- function(){
  conn <- dbConnect(RSQLite::SQLite(), 
                    DATABASE_FILE)
  
  dbGetQuery(
    conn,
    "SELECT SN.OID AS StudyNoteOID, 
     SNSR.ParentVerse, 
     SNT.ParentTopic
   FROM StudyNote SN
     LEFT JOIN StudyNoteScriptureReference SNSR
       ON SN.OID = SNSR.ParentStudyNote
     LEFT JOIN StudyNoteTopic SNT
       ON SN.OID = SNT.ParentStudyNote
  "
  )
}
