addNewTopic <- function(topic_text){
  conn <- dbConnect(RSQLite::SQLite(), 
                    DATABASE_FILE)
  on.exit({ dbDisconnect(conn) })
  
  topic_text <- trimws(topic_text)
  
  Current <- dbReadTable(conn, "Topic")
  
  if (tolower(topic_text) %in% tolower(Current$Topic)){
    return(Current)
  }
  
  statement <- "INSERT INTO [TOPIC] (Topic) VALUES (?topic_text)"
  
  res <- 
    dbSendStatement(
      conn, 
      sqlInterpolate(
        conn, 
        statement, 
        topic_text = topic_text
      )
    )
  dbClearResult(res)
  
  dbReadTable(conn, "Topic")
}
