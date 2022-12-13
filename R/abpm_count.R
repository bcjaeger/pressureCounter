

#' Count ABPM readings
#'
#' @param data a `data.frame` produced by [read_bpm].
#'
#' @return an integer vector (number of readings while awake and asleep)
#'
#' @export
#'
abpm_count <- function(data){

  abpm <- subset(data, mode == 'ABPM')

  abpm_valid <- subset(abpm, !is.na(sys) & !is.na(dia))

  abpm_periods <- rle(abpm_valid$awake)

  f_split <- rep(x = seq(length(abpm_periods$lengths)),
                 times = abpm_periods$lengths)

  f_tapply <- factor(abpm_periods$values,
                     levels = c(0, 1),
                     labels = c("Asleep", "Awake"))

  abpm_by_period <- split(abpm_valid, f = f_split)

  counts_by_period <- vapply(abpm_by_period,
                             FUN = nrow,
                             FUN.VALUE = integer(length = 1))

  out <- tapply(counts_by_period, f_tapply, sum)

  out[is.na(out)] <- 0

  out

  # data.frame(
  #   status = factor(abpm_periods$values, labels = c("Asleep", "Awake")),
  #   count = counts_by_period
  # )

}
