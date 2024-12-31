updateBookSelection <- function(tome_oid = 1, 
                                session = getDefaultReactiveDomain(), 
                                inputId = "sel_reference_book"){
  ThisBook <- BOOK[BOOK$ParentTome == tome_oid, ]
  sel_book <- ThisBook$OID
  names(sel_book) <- ThisBook$Title
  
  updateSelectInput(session = session, 
                    inputId = inputId, 
                    choices = sel_book, 
                    selected = sel_book[1])
  sel_book
}

updateChapterSelection <- function(book_oid = 1, 
                                   session = getDefaultReactiveDomain(), 
                                   inputId = "sel_reference_chapter"){
  ThisChap <- CHAPTER[CHAPTER$ParentBook == book_oid, ]
  sel_chap <- ThisChap$OID
  names(sel_chap) <- ThisChap$ChapterNumber
  
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
