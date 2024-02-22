
# TODO: include input for coordinator to say what grp participant was randomized to
# TODO: if assigned to ABPM first, ensure no HBPM before
# TODO: check if HBPM happens during ABPM
# TODO: check if ABPM happens during HBPM
# Allow early finish but check to make sure its all HBPM then all ABPM

#' run the application
#'
#' @return a shiny application
#'
#' @export
app_run <- function(){

  ui <- fluidPage(
    sidebarLayout(
      sidebarPanel(
        fileInput("file1", "Upload BP measurement file", accept = ".csv"),
      ),
      mainPanel(
        gt::gt_output("contents")
      )
    )
  )

  server <- function(input, output) {

    output$contents <- render_gt({

      file <- input$file1

      ext <- tools::file_ext(file$datapath)

      req(file)

      validate(need(ext == "csv", "Please upload a csv file"))

      data_in <- pressureCounter::read_bpm(file$datapath)

      data_notes <- pressureCounter::bp_interrogate(data_in)

      # initialize as 0 in case the participant didn't do it
      hbpm_tally <- 0
      abpm_tally <- c("Asleep" = 0, "Awake" = 0)

      tally_totals <- table(data_in$mode)

      if(tally_totals['HBPM'] > 0) hbpm_tally <- hbpm_count(data_in)
      if(tally_totals['ABPM'] > 0) abpm_tally <- abpm_count(data_in)

      data.frame(
        row = 'Count',
        hbpm = hbpm_tally,
        abpm_awake = abpm_tally['Awake'],
        abpm_asleep = abpm_tally['Asleep'],
        abpm_total = abpm_tally['Awake'] + abpm_tally['Asleep'],
        total = hbpm_tally + abpm_tally['Awake'] + abpm_tally['Asleep']
      ) |>
        gt(rowname_col = 'row') |>
        cols_label(hbpm = "Home BP monitoring",
                   abpm_awake = "Awake",
                   abpm_asleep = "Asleep",
                   abpm_total = "Total",
                   total = "Total (Home + Ambulatory)") |>
        tab_spanner(label = 'Ambulatory BP monitoring',
                    columns = c('abpm_awake', 'abpm_asleep', 'abpm_total')) |>
        cols_align('center') |>
        tab_source_note(data_notes)

    })
  }

  shinyApp(ui, server)

}
