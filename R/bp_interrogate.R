
#' Check for unexpected BP measurements
#'
#' @param data a data.frame object from `read_bpm()`
#'
#' @export
#'
#' @return text describing the measurements of HBPM and ABPM
#'
#'
bp_interrogate <- function(data){

  data_valid <- subset(data, !is.na(sys) & !is.na(dia))

  runs <- rle(as.integer(data_valid$mode))

  runs_data <- data.frame(
    length = runs$lengths,
    mode = levels(data$mode)[runs$values]
  )

  runs_data <- runs_data[!is.na(runs_data$mode), ]

  runs_data <- within(runs_data, {
    text = paste(length, "measurements of", mode)
  })


  runs_smry <- paste(runs_data$text, collapse = ', then ')

  output <- paste(
    "In the uploaded blood pressure (BP) measurements,",
    "I checked the order of ambulatory BP monitoring (ABPM)",
    "and home BP monitoring (HBPM). I found", runs_smry
  )

  # punctuation
  output <- paste0(output, ".")

  if(nrow(runs_data) > 2){
    output <- paste(output, "For the study, we hope to see a full sequence",
                    " of readings in the right order: ABPM and then HBPM",
                    "(Group 1) or HBPM and then ABPM (Group 2). If this is",
                    "Visit 2, please instruct the participant to do it in",
                    "the right order (and not go back and forth between the",
                    "two methods) between Visits 2 and 3")
  }

  output

}


