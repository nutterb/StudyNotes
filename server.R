shinyServer(function(input, output, session){
  
  # Notes - Reactive Values -----------------------------------------
  
  rv_Notes <- reactiveValues(
    AddEditView = "Add", 
    
    StudyNotes = getStudyNotes(DATABASE_FILE),
    
    SelectedStudyNote = data.frame(),
    
    SavedScripturalReference = numeric(0), 
    SavedOtherReference = numeric(0), 
    SavedStudyTopic = numeric(0),
    
    PendingScripturalReference = numeric(0), 
    PendingOtherReference = character(0), 
    PendingStudyTopic = numeric(0), 
    
    NoteHtmlCode = NULL
  )
  
  # Notes - Event Observers -----------------------------------------
  
  observeEvent(
    input$rdo_studyNote,
    {
      oid <- as.numeric(input$rdo_studyNote)
      rv_Notes$SelectedStudyNote <- rv_Notes$StudyNotes[rv_Notes$StudyNotes$OID == oid, ]
      rv_Notes$SavedScripturalReference <- getScripturalReference(oid)
      rv_Notes$SavedOtherReference <- getOtherReference(oid)
      rv_Notes$SavedStudyTopic <- getStudyTopic(oid)
    }
  )
  
  # Notes - Event Observers - Filter selection inputs ---------------
  
  observeEvent(
    input$sel_filterTome, 
    {
      book <- updateBookSelection(tome_oid = as.numeric(input$sel_filterTome), 
                                  inputId = "sel_filterBook", 
                                  selected = input$sel_filterBook)

      chapter <- updateChapterSelection(book_oid = as.numeric(input$sel_filterBook), 
                                        inputId = "sel_filterChapter")

      updateVerseSelection(chapter_oid = as.numeric(input$sel_filterChapter), 
                           inputId = "chkgrp_fingerVerse")
    }
  )
  
  observeEvent(
    input$sel_filterBook, 
    {
      req(input$sel_filterBook)

      chapter <- updateChapterSelection(book_oid = as.numeric(input$sel_filterBook), 
                                        inputId = "sel_filterChapter")
      updateVerseSelection(chapter_oid = as.numeric(input$sel_filterChapter), 
                           inputId = "chkgrp_filterVerse")
    }
  )
  
  observeEvent(
    input$sel_filterChapter,
    {
      req(input$sel_filterChapter)
      updateVerseSelection(chapter_oid = as.numeric(input$sel_filterChapter), 
                           inputId = "chkgrp_filterVerse")
    }
  )
  
  observeEvent(
    input$btn_clearFilters, 
    {
      updateSelectInput(session = session, 
                        inputId = "sel_filterTome", 
                        selected = "1")
      
      updateBookSelection(tome_oid = 1, 
                          inputId = "sel_filterBook")
      updateChapterSelection(book_oid = 1, 
                             inputId = "sel_filterChapter")
      updateVerseSelection(chapter_oid = 1, 
                           inputId = "chkgrp_filterVerse")
      updateSelectInput(session = session, 
                        inputId = "sel_filterTopic", 
                        selected = character(0))
      
      replaceData(proxy_dt_studyNotes,
                  rv_Notes$StudyNotes %>% 
                    radioDataTable(id_variable = "OID", 
                                   element_name = "rdo_studyNote"),
                  resetPaging = FALSE,
                  rownames = FALSE)
    }
  )
  
  observeEvent(
    input$btn_applyFilters,
    {
      FilterData <- getStudyNoteFilterData()
      
      is_in_group <- function(x, set) {
        if (length(set) == 0) {
          logical(0)
        } else if (length(set) == 1 && set == -1) {
          logical(0)
        } else {
          x %in% set
        }
      }
      
      lgl <- 
        list(
          is_in_group(FilterData$ParentTome, 
                      as.numeric(input$sel_filterTome)), 
          is_in_group(FilterData$ParentBook, 
                      as.numeric(input$sel_filterBook)), 
          is_in_group(FilterData$ParentChapter, 
                      as.numeric(input$sel_filterChapter)),
          is_in_group(FilterData$ParentVerse, 
                      as.numeric(input$chkgrp_filterVerse)), 
          is_in_group(FilterData$ParentTopic, 
                      as.numeric(input$sel_filterTopic))
        )
      
      lgl <- lgl[lengths(lgl) > 0]
      lgl <- Reduce(`&`, lgl)
      
      if (is.null(lgl)) lgl <- rep(TRUE, nrow(FilterData))
      
      FilterData <- FilterData[lgl, ]

      MatchingData <- rv_Notes$StudyNotes
      MatchingData <- MatchingData[MatchingData$OID %in% FilterData$StudyNoteOID, ]

      replaceData(proxy_dt_studyNotes,
                  MatchingData %>%
                    radioDataTable(id_variable = "OID",
                                   element_name = "rdo_studyNote"),
                  resetPaging = FALSE,
                  rownames = FALSE)
    }
  )
  
  # Notes - Event Observers - Add/Edit Buttons ----------------------
  
  observeEvent(
    input$btn_addStudyNote, 
    {
      rv_Notes$AddEditView <- "Add"
      
      updateCheckboxInput(session = session, 
                          inputId = "chk_studyNoteIsFutureResearch", 
                          value = FALSE)
      
      updateCheckboxInput(session = session, 
                          inputId = "chk_studyNoteIsPreparedTalk", 
                          value = FALSE)
      
      updateTextInput(session = session, 
                      inputId = "txt_studyNoteText", 
                      value = "")

     updateSelectInput(session = session, 
                       inputId = "sel_studyNoteTopic", 
                       selected = character(0))
     
     updateCheckboxGroupInput(inputId = "chkgrp_edit_reference", 
                              choices = character(0), 
                              selected = character(0))
     
     rv_Notes$PendingScripturalReference <- numeric(0)
     rv_Notes$PendingOtherReference <- character(0)
     rv_Notes$PendingStudyTopic <- numeric(0)
      
      toggleModal(session = session, 
                  modalId = "modal_studyNote", 
                  toggle = "open")
    }
  )
  
  observeEvent(
    input$btn_editSelectedNote, 
    {
      req(input$rdo_studyNote)
      rv_Notes$AddEditView <- "Edit"
      
      updateCheckboxInput(session = session, 
                          inputId = "chk_studyNoteIsFutureResearch", 
                          value = rv_Notes$SelectedStudyNote$IsFutureResearch)
      
      updateCheckboxInput(session = session, 
                          inputId = "chk_studyNoteIsPreparedTalk", 
                          value = rv_Notes$SelectedStudyNote$IsPreparedTalk)
      
      updateTextAreaInput(session = session, 
                          inputId = "txt_studyNoteText", 
                          value = rv_Notes$SelectedStudyNote$Note)
      
      updateSelectInput(session = session, 
                        inputId = "sel_reference_tome", 
                        selected = "1")
      
      updateBookSelection(tome_oid = 1)

      updateChapterSelection(book_oid = 1)
      
      updateVerseSelection(chapter_oid = 1)
      
      updateSelectInput(session = session, 
                        inputId = "sel_studyNoteTopic", 
                        selected = character(0))
      
      CurrentReference <- 
        getScripturalReference(input$rdo_studyNote) %>% 
        mutate(label = sprintf("%s %s:%s", 
                               Abbreviation, 
                               ChapterNumber, 
                               VerseNumber))
      chk_choice <- CurrentReference$OID
      names(chk_choice) <- CurrentReference$label
      updateCheckboxGroupInput(inputId = "chkgrp_edit_reference", 
                               choices = chk_choice, 
                               selected = chk_choice)
      
      rv_Notes$PendingScripturalReference <- numeric(0)
      rv_Notes$PendingOtherReference <- character(0)
      rv_Notes$PendingStudyTopic <- numeric(0)
      
      toggleModal(session = session, 
                  modalId = "modal_studyNote", 
                  toggle = "open")
    }
  )
  
  observeEvent(
    input$btn_saveStudyNote, 
    {
      study_note_oid <- if(rv_Notes$AddEditView == "Add") numeric(0) else as.numeric(input$rdo_studyNote)
      saveNote(note = input$txt_studyNoteText,
               is_future_research = input$chk_studyNoteIsFutureResearch, 
               is_prepared_talk = input$chk_studyNoteIsPreparedTalk,
               study_note_oid = study_note_oid,
               verse_oid = rv_Notes$PendingScripturalReference, 
               other_reference = rv_Notes$PendingOtherReference, 
               topic_oid = rv_Notes$PendingStudyTopic)
      
      rv_Notes$StudyNotes <- getStudyNotes(DATABASE_FILE)
      
      replaceData(proxy_dt_studyNotes,
                  rv_Notes$StudyNotes %>% 
                    radioDataTable(id_variable = "OID", 
                                   element_name = "rdo_studyNote", 
                                   checked = as.numeric(input$rdo_studyNote)),
                  resetPaging = FALSE,
                  rownames = FALSE)
      
      toggleModal(session = session, 
                  modalId = "modal_studyNote", 
                  toggle = "close")
    }
  )
  
  observeEvent(
    input$btn_update_reference, 
    {
      CurrentReference <- 
        getScripturalReference(input$rdo_studyNote)
      
      ref_to_remove <- setdiff(CurrentReference$OID, 
                               input$chkgrp_edit_reference)
      
      if (length(ref_to_remove) > 0) {
        removeScriptureReference(ref_to_remove)
        toggleModal(session = session, 
                    modalId = "modal_studyNote", 
                    toggle = "close")
      }
    }
  )
  
  # Notes - Event Observers - Reference selection inputs -------------
  
  observeEvent(
    input$sel_reference_tome, 
    {
      book <- updateBookSelection(tome_oid = as.numeric(input$sel_reference_tome))
      chapter <- updateChapterSelection(book_oid = book[1])
      updateVerseSelection(chapter_oid = chapter[1])
    }
  )
  
  observeEvent(
    input$sel_reference_book, 
    {
      req(input$sel_reference_book)
      chapter <- updateChapterSelection(book_oid = as.numeric(input$sel_reference_book))
      updateVerseSelection(chapter_oid = chapter[1])
    }
  )
  
  observeEvent(
    input$sel_reference_chapter,
    {
      req(input$sel_reference_chapter)
      updateVerseSelection(chapter_oid = as.numeric(input$sel_reference_chapter))
    }
  )
  
  # Notes - Event Observers - Add Reference button ------------------
  
  observeEvent(
    input$btn_addScriptureReference, 
    {
      req(input$chkgrp_reference_verse)
      rv_Notes$PendingScripturalReference <- 
        c(rv_Notes$PendingScripturalReference, 
          input$chkgrp_reference_verse)
      
      updateCheckboxGroupInput(session = session, 
                               inputId = "chkgrp_reference_verse", 
                               selected = character(0))
    }
  )
  
  observeEvent(
    input$btn_addOtherReference,
    {
      req(trimws(input$txt_otherReference))
      rv_Notes$PendingOtherReference <- 
        c(rv_Notes$PendingOtherReference, 
          input$txt_otherReference)
      
      
      updateTextInput(session = session, 
                      inputId = "txt_otherReference", 
                      value = character(0))
    }
  )
  
  observeEvent(
    input$btn_addStudyNoteTopic, 
    {
      req(input$sel_studyNoteTopic)

      rv_Notes$PendingStudyTopic <- as.numeric(input$sel_studyNoteTopic)
    }
  )
  

  
  # Notes - Event Observers - View Note -----------------------------
  
  observeEvent(
    input$btn_viewSelectedNote, 
    {
      write_to <- tempfile(fileext = ".html")

      rmarkdown::render(input = "StudyNoteTemplate.Rmd", 
                        output_format = "html_document", 
                        output_file = basename(write_to), 
                        output_dir = dirname(write_to), 
                        params = list(study_note_oid = input$rdo_studyNote, 
                                      database_file = DATABASE_FILE))
      
      
      html <- readLines(write_to,
                        encoding = "UTF-8")
      html <- paste0(html, collapse = "\n")
      html <- sub("^.+[<]body[>]", "<div>", html)
      html <- sub("[<]/body[>].+", "</div>", html)
      
      rv_Notes$NoteHtmlCode <- html
      
      toggleModal(session = session, 
                  modalId = "modal_viewStudyNote", 
                  toggle = "open")
    }
  )
  
  # Notes - Download Handlers ---------------------------------------
  
  output$dwn_studyNote <- 
    downloadHandler(
      filename = "StudyNote.html", 
      content = function(file){
        rmarkdown::render(input = "StudyNoteTemplate.Rmd", 
                          output_format = "html_document", 
                          output_file = basename(file), 
                          output_dir = dirname(file), 
                          params = list(study_note_oid = input$rdo_studyNote, 
                                        database_file = DATABASE_FILE))
      }
    )
  
  # Notes - Output --------------------------------------------------
  
  output$txt_modalStudyNote_Title <- 
    renderText({
      sprintf("%s a Note", 
              rv_Notes$AddEditView)
    })
  
  output$dt_studyNotes <- 
    DT::renderDataTable({
      getStudyNotes(DATABASE_FILE) %>% 
        radioDataTable(id_variable = "OID", 
                       element_name = "rdo_studyNote") %>% 
      DT::datatable(selection = "none", 
                    escape = -1, 
                    rownames = FALSE, 
                    filter = "top")
    })
  
  proxy_dt_studyNotes <- DT::dataTableProxy("dt_studyNotes")
  
  output$txt_savedScripturalReference <- 
    renderText({
      req(rv_Notes$SavedScripturalReference, 
          rv_Notes$AddEditView == "Edit")

      sprintf("Scriptural References: %s", 
              formatScriptureReference(rv_Notes$SavedScripturalReference$ParentVerse))
      
    })
  
  output$txt_savedOtherReference <-
    renderText({
      req(rv_Notes$SavedOtherReference, 
          rv_Notes$AddEditView == "Edit")
      sprintf("Other Reference: %s", 
              paste0(rv_Notes$SavedOtherReference$Reference, 
                     collapse = "<br/>")) %>% 
        HTML()
    })
  
  output$txt_savedStudyNoteTopic <- 
    renderText({
      req(rv_Notes$SavedStudyTopic, 
          rv_Notes$AddEditView == "Edit")
      print(rv_Notes$SavedStudyTopic)
      ThisTopic <- rv_Topics$Topics
      ThisTopic <- ThisTopic[ThisTopic$OID %in% rv_Notes$SavedStudyTopic$ParentTopic, ]
      
      sprintf("Topics: %s", 
              paste0(sort(ThisTopic$Topic), 
                     collapse = ",")) 
    })
  
  output$txt_pendingScripturalReference <- 
    renderText({
      req(rv_Notes$PendingScripturalReference)
      sprintf("Pending Scriptural References: %s", 
              formatScriptureReference(rv_Notes$PendingScripturalReference))
      
    })
  
  output$txt_pendingOtherReference <-
    renderText({
      req(rv_Notes$PendingOtherReference)
      sprintf("Pending Other Reference: %s", 
              paste0(rv_Notes$PendingOtherReference, 
                     collapse = "<br/>")) %>% 
        HTML()
    })
  
  output$txt_pendingStudyNoteTopic <- 
    renderText({
      req(rv_Notes$PendingStudyTopic)
      
      ThisTopic <- rv_Topics$Topics
      ThisTopic <- ThisTopic[ThisTopic$OID %in% rv_Notes$PendingStudyTopic, ]
      
      sprintf("Pending Topics: %s", 
              paste0(sort(ThisTopic$Topic), 
                     collapse = ",")) 
    })
  
  output$view_studyNote <- 
    renderUI({
      HTML(rv_Notes$NoteHtmlCode)
    })
  
  # Topics - Reactive Values ----------------------------------------
  
  rv_Topics <- reactiveValues(
    Topics = TOPIC
  )
  
  # Topics - Event Observers ----------------------------------------
  
  observeEvent(
    rv_Topics$Topics, 
    {
      choice <- rv_Topics$Topics
      choice <- choice[order(choice$Topic), ]
      
      display <- choice$OID
      names(display) <- choice$Topic
      
      updateSelectInput(session= session, 
                        inputId = "sel_studyNoteTopic", 
                        choices = display)
      
      updateSelectInput(session= session, 
                        inputId = "sel_filterTopic", 
                        choices = display)
    }
  )
  
  observeEvent(
    input$btn_addTopic, 
    {
      req(trimws(input$txt_newTopic) != "")
      
      rv_Topics$Topics <- addNewTopic(input$txt_newTopic)
      
      DT::replaceData(proxy_dt_topicList, 
                      rv_Topics$Topics %>% arrange(Topic),
                      resetPaging = FALSE,
                      rownames = FALSE)
      
      updateTextInput(session = session, 
                      inputId = "txt_newTopic", 
                      value = "")
    }
  )
  
  # Topics - Output -------------------------------------------------
  
  output$dt_topicList <- 
    DT::renderDataTable({
      DT::datatable(TOPIC %>% arrange(Topic),
                    rownames = FALSE)
    })
  
  proxy_dt_topicList <- DT::dataTableProxy("dt_topicList")
  
})