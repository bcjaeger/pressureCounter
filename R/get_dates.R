
get_dates <- function(x){

  dates_out <- suppressWarnings( lubridate::mdy(x) )

  if(all(is.na(dates_out))){
    dates_out <- suppressWarnings( lubridate::ymd(x) )
  }

  if(all(is.na(dates_out))){
    stop("could not parse dates in the input data. ",
         "Are they in the format of Month/Day/Year?",
         call. = FALSE)
  }

  dates_out

}
