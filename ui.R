dashboardPage(
  title = "Study Notes",
  # Dashboard Header ------------------------------------------------
  dashboardHeader(
    title = "Study Notes", 
    titleWidth = 250
  ), 
  
  # Dashboard Sidebar -----------------------------------------------
  dashboardSidebar(
    width = 250, 
    sidebarMenu(
      menuItem("Notes", 
               tabName = "tab_studyNotes"), 
      menuItem("Topics", 
               tabName = "tab_topics")
    )
  ), 
  
  # Dashboard Body --------------------------------------------------
  dashboardBody(
    useShinyjs(),
    tags$head(tags$style(HTML('

                        .modal-lg {
                        width: 90%;

                        }
                      '))),
    
    # Modals --------------------------------------------------------
    
    bsModal(
      id = "modal_studyNote", 
      title = textOutput("txt_modalStudyNote_Title"), 
      trigger = "trg_none", 
      size = "large", 
      
      fluidRow(
        column(
          width = 6, 
          checkboxInput(inputId = "chk_studyNoteIsFutureResearch", 
                        label = "Mark for Future Research"),
          checkboxInput(inputId = "chk_studyNoteIsPreparedTalk", 
                        label = "Prepared Talk"),
          textAreaInput(inputId = "txt_studyNoteText", 
                        label = "Study Note", 
                        width = "100%", 
                        height = "400px"), 
          fluidRow(
            column(
              width = 6, 
              textOutput("txt_savedStudyNoteTopic"),
              textOutput("txt_savedScripturalReference"),
              uiOutput("txt_savedOtherReference")
            ),
            column(
              width = 6,
              span(textOutput(outputId = "txt_pendingStudyNoteTopic"),
                   style = "color:purple;font-weight:bold;"),
              span(textOutput(outputId = "txt_pendingScripturalReference"),
                   style = "color:purple;font-weight:bold;"),
              span(uiOutput(outputId = "txt_pendingOtherReference"),
                   style = "color:purple;font-weight:bold;")
            )
          ),
          actionButton(inputId = "btn_saveStudyNote", 
                       label = "Save Note")
        ), 
        column(
          width = 3,
          fluidRow(
            selectInput(inputId = "sel_reference_tome", 
                        label = "Tome", 
                        choices = setNames(TOME$OID, TOME$Title)),
            selectInput(inputId = "sel_reference_book", 
                        label = "Book", 
                        choices = NULL), 
            selectInput(inputId = "sel_reference_chapter", 
                        label = "Chapter", 
                        choices = NULL), 
            checkboxGroupInput(inputId = "chkgrp_reference_verse", 
                               label = "Verse", 
                               choices = NULL, 
                               inline = TRUE), 
            actionButton(inputId = "btn_addScriptureReference", 
                         label = "Add Scripture Reference")
          )
        ), 
        column(
          width = 3, 
          textInput(inputId = "txt_otherReference", 
                    label = "Non-Scriptural Reference", 
                    width = "100%"), 
          actionButton(inputId = "btn_addOtherReference", 
                       label = "Add Non Scriptural Reference"), 
          selectInput(inputId = "sel_studyNoteTopic", 
                      label = "Topic", 
                      choices = character(0), 
                      multiple = TRUE, 
                      selectize = FALSE, 
                      size = 20),
          actionButton(inputId = "btn_addStudyNoteTopic", 
                       label = "Add Topics")
        )
      )
    ),
    
    
    bsModal(
      id = "modal_viewStudyNote", 
      title = "Study Note Preview", 
      trigger = "trg_none", 
      size = "large", 
      uiOutput("view_studyNote")
    ),
    
    # UI Body -------------------------------------------------------
    tabItems(
      tabItem(
        "tab_studyNotes",
        actionButton(inputId = "btn_addStudyNote", 
                     label = "Add Note"), 
        actionButton(inputId = "btn_editSelectedNote", 
                     label = "Edit Selected"), 
        actionButton(inputId = "btn_viewSelectedNote", 
                     label = "View Selected"),
        downloadButton(outputId = "dwn_studyNote", 
                       label = "Download Note"),
        
        fluidRow(
          column(
            width = 2, 
            selectInput(inputId = "sel_filterTome", 
                        label = "Tome", 
                        choices = setNames(TOME$OID, TOME$Title))
          ), 
          column(
            width = 2,
            selectInput(inputId = "sel_filterBook", 
                        label = "Book", 
                        choices = character(0))
          ), 
          column(
            width = 1, 
            selectInput(inputId = "sel_filterChapter", 
                        label = "Chapter", 
                        choices = character(0))
          ), 
          column(
            width = 3, 
            checkboxGroupInput(inputId = "chkgrp_filterVerse", 
                               label = "Verse", 
                               choices = character(0), 
                               inline = TRUE)
          ), 
          column(
            width = 2, 
            selectInput(inputId = "sel_filterTopic", 
                        label = "Topic", 
                        choices = setNames(TOPIC$OID, TOPIC$Topic), 
                        multiple = TRUE, 
                        selectize = FALSE, 
                        size = 10)
          ),
          column(
            width = 1,
            actionButton(inputId = "btn_applyFilters", 
                         label = "Apply Filters", 
                         style = "float:right;"),
            actionButton(inputId = "btn_clearFilters", 
                         label = "Clear Filters", 
                         style = "float:right;")
          )
          
        ),
        
        radioDataTableOutput("dt_studyNotes", 
                             radioId = "rdo_studyNote")
      ), 
      tabItem(
        "tab_topics", 
        fluidRow(
          column(
            width = 2, 
            textInput(inputId = "txt_newTopic", 
                      label = "Topic to Add"), 
            actionButton(inputId = "btn_addTopic", 
                         label = "Add")
          ), 
          column(
            width = 10, 
            DT::dataTableOutput("dt_topicList")
          )
        )
      )
    )
  )
)