formatScriptureReference <- function(verse_oid){
  conn <- dbConnect(RSQLite::SQLite(), 
                    DATABASE_FILE)
  on.exit({ dbDisconnect(conn) })
  
  verse_oid <- unique(verse_oid)
  verse_in <- glue::glue_sql("{verse_oid*}", 
                             .con = conn)
  
  Ref <- DBI::dbGetQuery(
    conn,
    DBI::sqlInterpolate(
      conn,
      "SELECT DISTINCT
       B.Title AS Book, 
       B.Abbreviation,
       C.ChapterNumber, 
       V.VerseNumber 
       FROM Verse V
        LEFT JOIN Chapter C
          ON V.ParentChapter = C.OID
        LEFT JOIN Book B
          ON C.ParentBook = B.OID
       WHERE V.OID IN (?verse_in)",
      verse_in = verse_in
    )
  ) %>% 
    group_by(Book, Abbreviation, ChapterNumber) %>% 
    summarise(VerseNumber = consolidateVerse(VerseNumber)) %>% 
    mutate(Ref = sprintf("%s %s:%s", 
                         Abbreviation, 
                         ChapterNumber, 
                         VerseNumber))
  
  paste0(Ref$Ref, 
         collapse = "; ")
}

consolidateVerse <- function(verse){
  verse <- sort(verse)
  diff_verse <- c(1, diff(verse))
  
  group <- cumsum(diff_verse != 1)
  
  grouping <- split(verse, group)
  
  grouping <- lapply(grouping, 
                     function(g){
                       if (length(g) == 1){
                         g
                       } else {
                         sprintf("%s-%s", 
                                 min(g), 
                                 max(g))
                       }
                     })
  
  paste0(unlist(grouping), 
         collapse = ",")
  
}
