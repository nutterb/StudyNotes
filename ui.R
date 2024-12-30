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
      menuItem("Search by Verse", 
               tabName = "tab_searchByVerse")
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
          width = 8, 
          textAreaInput(inputId = "txt_studyNoteText", 
                        label = "Study Note", 
                        width = "100%", 
                        height = "400px"), 
          fluidRow(
            column(
              width = 6, 
              textOutput("txt_savedScripturalReference"),
              uiOutput("txt_savedOtherReference")
            ),
            column(
              width = 6,
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
          width = 4,
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
                         label = "Add Scripture Reference"), 
            textInput(inputId = "txt_otherReference", 
                      label = "Non-Scriptural Reference", 
                      width = "100%"), 
            actionButton(inputId = "btn_addOtherReference", 
                         label = "Add Non Scriptural Reference")
          )
        )
      )
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
        radioDataTableOutput("dt_studyNotes", 
                             radioId = "rdo_studyNote")
      ), 
      tabItem(
        "tab_searchByVerse"
      )
    )
  )
)