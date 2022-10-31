
## code to prepare `example_1` dataset goes here

example_1 <- read_bpm('data-raw/example_1.csv')
usethis::use_data(example_1, overwrite = TRUE)

example_2 <- read_bpm('data-raw/example_2.csv')
usethis::use_data(example_2, overwrite = TRUE)
