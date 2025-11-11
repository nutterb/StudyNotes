getStudyNoteFilterData <- function(){
  conn <- dbConnect(RSQLite::SQLite(), 
                    DATABASE_FILE)
  
  dbGetQuery(
    conn,
    "SELECT SN.OID AS StudyNoteOID, 
    SNSR.ParentVerse, 
    V.ParentChapter, 
    C.ParentBook, 
    B.ParentTome, 
    SNT.ParentTopic
   FROM StudyNote SN
    LEFT JOIN StudyNoteScriptureReference SNSR
      ON SN.OID = SNSR.ParentStudyNote
    LEFT JOIN Verse V
      ON SNSR.ParentVerse = V.OID
    LEFT JOIN Chapter C
      ON V.ParentChapter = C.OID
    LEFT JOIN Book B
      ON C.ParentBook = B.OID
    LEFT JOIN StudyNoteTopic SNT
       ON SN.OID = SNT.ParentStudyNote
  "
  )
}
