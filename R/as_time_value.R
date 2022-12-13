

as_time_value <- function(x){

  out <- strptime(x, format = "%Y/%m/%d %H:%M")

  if(all(is.na(out)))
    out <- strptime(x, format = "%Y-%m-%d %H:%M")

  out

}
