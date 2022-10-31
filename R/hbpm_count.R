

#' Count HBPM readings
#'
#' @param data a `data.frame` produced by [read_bpm].
#'
#' @param max_per_day maximum number of readings per day. For example,
#'   if `max_per_day` is 4 and there are 5 readings that day, then only
#'   4 of those 5 count for that day.
#'
#' @return an integer (number of HBPM readings)
#'
#' @export
#'
#' @details
#'
#'  - so for example, 5 readings on one day counts as 4 readings)
#'
hbpm_count <- function(data, max_per_day = 4){

  hbpm <- subset(data, mode == 'HBPM')

  hbpm_valid <- subset(hbpm, !is.na(sys) & !is.na(dia))

  f_split <- factor(format(hbpm_valid$measure_time, '%d'))

  hbpm_by_day <- split(hbpm_valid, f = f_split)

  counts_by_day <- vapply(hbpm_by_day,
                          FUN = nrow,
                          FUN.VALUE = integer(length = 1))

  sum(pmin(counts_by_day, max_per_day))

}
