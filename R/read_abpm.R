

#' Read and clean BP monitoring data
#'
#' @param fpath path to the abpm file
#'
#' @return a data.frame with bp values
#'
#' @export
#'

read_bpm <- function(fpath){

  input_sleep <- data.table::fread(fpath, fill = TRUE, skip = 3, nrows = 1)
  input_data <- data.table::fread(fpath, fill = TRUE, skip = 7)

  input_sleep <- as.data.frame(input_sleep)

  names(input_sleep) <- c('SLEEP.TIME', 'WAKE.TIME')

  input_data <- as.data.frame(input_data)

  # input_sleep <- read.csv(fpath, skip = 2, nrows = 1)
  # input_data <- read.csv(fpath, skip = 4)

  names(input_data) <- tolower(names(input_data))

  input_data$mode <- factor(input_data$mode,
                            levels = c(3, 10),
                            labels = c("HBPM", "ABPM"))

  input_data$measure_time <- paste(input_data$date,
                                   input_data$time,
                                   sep = ' ')

  input_data$measure_time <- strptime(input_data$measure_time,
                                      format = "%Y/%m/%d %H:%M")


  sleep_time <- format(
    as.POSIXct(input_sleep$SLEEP.TIME, format='%I:%M %p'),
    format="%H:%M:%S"
  )

  sleep_time <- strptime(
    paste(input_data$date, sleep_time, sep = ' '),
    "%Y/%m/%d %H:%M:%S"
  )

  awake_time <- format(
    as.POSIXct(input_sleep$WAKE.TIME, format='%I:%M %p'),
    format="%H:%M:%S"
  )

  awake_time <- strptime(
    paste(input_data$date, awake_time, sep = ' '),
    "%Y/%m/%d %H:%M:%S"
  )

  input_data$sleep_time <- sleep_time
  input_data$awake_time <- awake_time

  if(grepl(pattern = 'AM',
           x = input_sleep$SLEEP.TIME,
           fixed = TRUE)){

    input_data$awake <- ifelse(
      test = with(
        input_data,
        measure_time >= sleep_time & measure_time <= awake_time
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
        measure_time >= sleep_time | measure_time <= awake_time
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
