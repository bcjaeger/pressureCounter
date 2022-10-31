
#' run the application
#'
#' @return
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

      hbpm_tally <- hbpm_count(data_in)
      abpm_tally <- abpm_count(data_in)

      data.frame(
        row = 'Count',
        hbpm = hbpm_tally,
        abpm_awake = abpm_tally['Awake'],
        abpm_asleep = abpm_tally['Asleep']
      ) |>
        gt(rowname_col = 'row') |>
        cols_label(hbpm = "Home BP monitoring",
                   abpm_awake = "Awake",
                   abpm_asleep = "Asleep") |>
        tab_spanner(label = 'Ambulatory BP monitoring',
                    columns = c('abpm_awake', 'abpm_asleep')) |>
        cols_align('center')

    })
  }

  shinyApp(ui, server)

}
