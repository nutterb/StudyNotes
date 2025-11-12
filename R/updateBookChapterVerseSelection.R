updateBookSelection <- function(tome_oid = 1, 
                                session = getDefaultReactiveDomain(), 
                                inputId = "sel_reference_book", 
                                with_any = FALSE, 
                                selected = character(0)){
  ThisBook <- 
    BOOK[BOOK$ParentTome %in% tome_oid, ]
  
  sel_book <- c(if (with_any) -1 else numeric(0), 
                ThisBook$OID)
  names(sel_book) <- c(if (with_any) "Any" else numeric(0), 
                       ThisBook$Title)

  this_sel <- selected[selected %in% sel_book]
  
  updateSelectInput(session = session, 
                    inputId = inputId, 
                    choices = sel_book, 
                    selected = this_sel)
  sel_book
}

updateChapterSelection <- function(book_oid = 1, 
                                   session = getDefaultReactiveDomain(), 
                                   inputId = "sel_reference_chapter", 
                                   with_any = FALSE, 
                                   selected = character(0)){
  if (length(book_oid) != 1) {
    sel_chap <- character(0)
    selected <- character(0)
  } else {
    ThisChap <- CHAPTER[CHAPTER$ParentBook %in% book_oid, ]
    
    sel_chap <- c(if (with_any) -1 else numeric(0), 
                  ThisChap$OID)
    
    names(sel_chap) <- c(if (with_any) "Any" else character(0), 
                         ThisChap$ChapterNumber)
  }

  updateSelectInput(session = session,
                    inputId = inputId,
                    choices = sel_chap, 
                    selected = selected)

  sel_chap
}

updateVerseSelection <- function(chapter_oid = 1, 
                                 session = getDefaultReactiveDomain(), 
                                 inputId = "chkgrp_reference_verse", 
                                 selected = character(0)){
  if (length(chapter_oid) != 1) {
    sel_verse <- character(0)
    selected <- character(0)
  } else {
    ThisVerse <- VERSE[VERSE$ParentChapter == chapter_oid, ]
    sel_verse <- ThisVerse$OID
    names(sel_verse) <- ThisVerse$VerseNumber
  }
  
  updateCheckboxGroupInput(session = session, 
                           inputId = inputId, 
                           choices = sel_verse, 
                           selected = character(0), 
                           inline = TRUE)
  sel_verse
}
