updateBookSelection <- function(tome_oid = 1, 
                                session = getDefaultReactiveDomain(), 
                                inputId = "sel_reference_book", 
                                with_any = FALSE){
  ThisBook <- BOOK[BOOK$ParentTome == tome_oid, ]
  sel_book <- c(if (with_any) -1 else numeric(0), 
                ThisBook$OID)
  names(sel_book) <- c(if (with_any) "Any" else numeric(0), 
                       ThisBook$Title)
  
  updateSelectInput(session = session, 
                    inputId = inputId, 
                    choices = sel_book, 
                    selected = sel_book[1])
  sel_book
}

updateChapterSelection <- function(book_oid = 1, 
                                   session = getDefaultReactiveDomain(), 
                                   inputId = "sel_reference_chapter", 
                                   with_any = FALSE){
  ThisChap <- CHAPTER[CHAPTER$ParentBook == book_oid, ]
  
  sel_chap <- c(if (with_any) -1 else numeric(0), 
                ThisChap$OID)

  names(sel_chap) <- c(if (with_any) "Any" else character(0), 
                       ThisChap$ChapterNumber)

  updateSelectInput(session = session,
                    inputId = inputId,
                    choices = sel_chap, 
                    selected = sel_chap[1])

  sel_chap
}

updateVerseSelection <- function(chapter_oid = 1, 
                                 session = getDefaultReactiveDomain(), 
                                 inputId = "chkgrp_reference_verse"){
  ThisVerse <- VERSE[VERSE$ParentChapter == chapter_oid, ]
  sel_verse <- ThisVerse$OID
  names(sel_verse) <- ThisVerse$VerseNumber
  
  updateCheckboxGroupInput(session = session, 
                           inputId = inputId, 
                           choices = sel_verse, 
                           selected = character(0), 
                           inline = TRUE)
  sel_verse
}
