# TODO: Move to tools/config sections only

#' Removes std::cerr references from files.
#'
#' @param pkg_path character giving path to the package
#'
#' @return None.
#' 
#' @details changes the downloaded files to R outputs
#' 
#' @keywords internal
.cgal.cerr.remover <- function(pkg_path = NULL) {
  
  if (is.null(pkg_path)) {
    pkg_path <- dirname(system.file(".", package = "RcppCGAL"))
  }
  dest_folder <- file.path(pkg_path, "include", "CGAL")
  
  # check to see if changes have already been done before
  # change_log_dir <- file.path(pkg_path, "saveCheck")
  # stored_change_log <- file.path(change_log_dir, "OUTPUT_CHANGED")
  # 
  # if(!file.exists(stored_change_log)) {
  #   if(!dir.exists(change_log_dir)) dir.create(change_log_dir)
  #   file.create(stored_change_log)
  # }
  # CHANGED <- readLines(stored_change_log)
  # if(isTRUE(CHANGED == "TRUE")) {
  #   return(invisible())
  # }
  # CHANGED <- isTRUE(cgal_pkg_state$CLEANED)
  # if(CHANGED) {
  #   return(invisible(NULL))
  # }
  
  # change files
  message("\nChanging CGAL's message output to R's output...\n")
  files <- list.files(path = dest_folder, all.files = TRUE,
                      full.names = TRUE, recursive = TRUE)
  tx <- first <- search <- NULL
  for (f in files) {
    
    # append new line to all files
    cat("\n", file = f, append = TRUE) # only two files are problematic but easier than searching in R
    
    # read in header file to search for problems
    tx  <- readLines(f, warn = TRUE)
    
    # # test code to avoid having to add new line to all files...may not be worth it.
    # # setup warning environment
    # warnlist <- list2env(list(w = FALSE))
    # no_endline <- FALSE
    # 
    # # check for warning AND get file
    # tx <- withCallingHandlers(
    #   tryCatch(readLines(f, warn = TRUE)),
    #   warning = function(w){warnlist$w <- TRUE; invokeRestart("muffleWarning")})
    # if (isTRUE(warnlist$w)) {
    #  no_endline <- TRUE
    # }
    
    # search for problem functions
    search  <- grep(pattern = "std::cerr|std::cout|abort\\(|exit\\(", x = tx)
    abn_end <- length(search) > 0 # returns true if any found
    
    if(!abn_end) next
    
    # search for problematic functions if present
    tx[1] <- paste0("#include <Rcpp.h>\n", tx[1])
    tx[search]  <- gsub(pattern = "std::tuple<Locate_type, int, int> exit\\(\\) const", 
                        replacement="std::tuple<Locate_type, int, int\\> exit_tmp\\(\\) const", 
                        x = tx[search])
    tx[search]  <- gsub(pattern = "std::cerr", replacement = "Rcpp::Rcerr", x = tx[search])
    tx[search]  <- gsub(pattern = "std::cout", replacement = "Rcpp::Rcout", x = tx[search])
    tx[search]  <- gsub(pattern = "std::abort\\(\\)", replacement = 'Rcpp::stop("Error")', x = tx[search])
    tx[search]  <- gsub(pattern = " abort\\(\\)", replacement = 'Rcpp::stop("Error")', x = tx[search])
    tx[search]  <- gsub(pattern = "std::exit\\(\\)", replacement = 'Rcpp::stop("Error")', x = tx[search])
    tx[search]  <- gsub(pattern = " exit\\(\\)", replacement = 'Rcpp::stop("Error")', x = tx[search])
    tx[search]  <- gsub(pattern = "std::exit\\(0\\)", replacement = 'Rcpp::stop("Success")', x = tx[search])
    tx[search]  <- gsub(pattern = "std::exit\\(1\\)", replacement = 'Rcpp::stop("Error")', x = tx[search])
    tx[search]  <- gsub(pattern = "std::tuple<Locate_type, int, int> exit_tmp\\(\\) const", 
                        replacement="std::tuple<Locate_type, int, int\\> exit\\(\\) const", 
                        x = tx[search])
    writeLines(tx, con=f)
    
  }
  return(invisible(NULL))
}


# for use on my machine to change files uploaded to github
.cgal.cerr.remover.github <- function() {
  path <- file.path(getwd(), "inst")
  .cgal.cerr.remover(path)
  return(invisible())
}
