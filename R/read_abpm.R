

#' Read and clean BP monitoring data
#'
#' @param fpath path to the abpm file
#'
#' @return a data.frame with bp values
#'
#' @export
#'

read_bpm <- function(fpath,
                     sleep_skip_max=15,
                     data_skip_max=15,
                     input_sleep_expected_names = c('SLEEP TIME', 'WAKE TIME'),
                     input_data_expected_names = c("DATE",
                                                   "TIME",
                                                   "SYS",
                                                   "MAP",
                                                   "DIA",
                                                   "PUL",
                                                   "Err",
                                                   "Artifact",
                                                   "Stat",
                                                   "Mode",
                                                   "E08",
                                                   "Temperature",
                                                   "Atmosphere")){



  sleep_skip <- sleep_skip_max + 1
  sleep_names_match <- FALSE

  data_skip <- data_skip_max + 1
  data_names_match <- FALSE

  suppressWarnings({

    while(!sleep_names_match){

      sleep_skip <- sleep_skip - 1

      if(sleep_skip < 0) stop(
        "Could not identify sleep data.",
        "\nDoes the file have a row that looks like this?\n\n",
        paste(input_sleep_expected_names, collapse = ', '),
        call. = FALSE
      )

      input_sleep <- data.table::fread(fpath,
                                       fill = TRUE,
                                       skip = sleep_skip,
                                       header = TRUE,
                                       nrows = 1)

      sleep_names_match <- all(
        names(input_sleep)[1:2] == input_sleep_expected_names
      )

    }

    while(!data_names_match){

      data_skip <- data_skip - 1

      if(data_skip < 0) stop(
        "Could not identify BP data.",
        "\nDoes the file have a row that looks like this?\n\n",
        paste(input_data_expected_names, collapse = ', '),
        call. = FALSE
      )

      input_data <- data.table::fread(fpath,
                                      fill = TRUE,
                                      skip = data_skip)

      data_names_match <- all(
        names(input_data) == input_data_expected_names
      )

    }

  })

  input_sleep <- as.data.frame(input_sleep)[, input_sleep_expected_names]
  names(input_sleep) <- c('SLEEP.TIME', 'WAKE.TIME')

  input_data <- as.data.frame(input_data)
  names(input_data) <- tolower(names(input_data))

  input_data$date <- get_dates(input_data$date)

  input_data$mode <- factor(input_data$mode,
                            levels = c(3, 10),
                            labels = c("HBPM", "ABPM"))

  input_data$measure_time <- paste(input_data$date,
                                   input_data$time,
                                   sep = ' ')


  input_data$measure_time <- as_time_value(input_data$measure_time)

  sleep_time <- format(
    as.POSIXct(input_sleep$SLEEP.TIME, format='%I:%M %p'),
    format="%H:%M:%S"
  )

  awake_time <- format(
    as.POSIXct(input_sleep$WAKE.TIME, format='%I:%M %p'),
    format="%H:%M:%S"
  )

  sleep_time <- as_time_value(paste(input_data$date, sleep_time))
  awake_time <- as_time_value(paste(input_data$date, awake_time))

  input_data$sleep_time <- sleep_time
  input_data$awake_time <- awake_time

  if(grepl(pattern = 'AM',
           x = input_sleep$SLEEP.TIME,
           fixed = TRUE)){

    input_data$awake <- ifelse(
      test = with(
        input_data,
        measure_time > sleep_time & measure_time < awake_time
      ),
      yes = 0,
      no = 1
    )

  } else if (grepl(pattern = 'PM',
                   x = input_sleep$SLEEP.TIME,
                   fixed = TRUE)){

    input_data$awake <- ifelse(
      test = with(
        input_data,
        measure_time > sleep_time | measure_time < awake_time
      ),
      yes = 0,
      no = 1
    )

  }

  input_data[,c('measure_time',
                'sleep_time',
                'awake_time',
                'awake',
                'sys',
                'map',
                'dia',
                'mode')]




}
