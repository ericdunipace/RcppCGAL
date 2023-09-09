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
  CHANGED <- isTRUE(cgal_pkg_state$CLEANED)
  if(CHANGED) {
    return(invisible(NULL))
  }
  
  # change files
  message("\nChanging CGAL's message output to R's output...\n")
  files <- list.files(path = dest_folder, all.files = TRUE,
                      full.names = TRUE, recursive = TRUE)
  tx <- first <- search <- NULL
  for (f in files) {
    tx  <- readLines(f, warn = FALSE)
    # if (grepl("Uncertain.h",f ) ) { # avoid warning for boolean operators in other packages with CRAN clang checks
    #   # browser()
    #   lines <- grep(pattern = "return Uncertain<bool>", x = tx)
    #   tx[lines] <- gsub(pattern = "(?:(\\|)(?!\1))+", 
    #                     replacement = "\\|\\|",
    #                     x = tx[lines], perl = TRUE)
    #   tx[lines] <- gsub(pattern = "(?:(&)(?!\1))+", 
    #                     replacement = "&&",
    #                     x = tx[lines], perl = TRUE)
    #   writeLines(tx, con=f)
    # } # this code is no longer neaded after issue
    
    search <- grep(pattern = "std::cerr|std::cout|abort\\(|exit\\(", x = tx)
    if (length(search)==0) next
    # first <- grep("#include", tx)[1]
    # tx[first]  <- sub(pattern = "#include",   replacement = "#include <Rcpp.h>\n#include", x = tx[first])
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
  cgal_pkg_state$CLEANED <- TRUE
  # assign("cgal_pkg_state", "cgal_pkg_state", pos = "package:RcppCGAL")
  return(invisible(NULL))
}


# for use on my machine to change files uploaded to github
.cgal.cerr.remover.github <- function() {
  path <- file.path(getwd(), "inst")
  .cgal.cerr.remover(path)
  return(invisible())
}
