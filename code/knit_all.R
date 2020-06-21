# Source this scrip to knit all documents in order

tictoc::tic()

prep_fn <- 
  list.files("code/preprocessing/", pattern = "\\.Rmd", full = TRUE)

analysis_fn <- 
  list.files("code/analysis/", pattern = "\\.Rmd", full = TRUE)
# Don't knit the child (prep) document
analysis_fn <- analysis_fn[ -grep("/0-", analysis_fn) ]


system.time(lapply(prep_fn, rmarkdown::render, envir = new.env()))

system.time(lapply(analysis_fn, rmarkdown::render, envir = new.env()))

tictoc::toc()