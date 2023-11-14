
# If interactive will ask to DL and then warn if not downloaded
.cgal_download_check <- function(silent = FALSE) {
  interact <- interactive()
  
  # setup warning messages
  warn_mess <- "\nCGAL header files not found on installation. If you tried to install them manually, something didn't work. See the installation vignette for help. If you believe this is a bug, please report it!."
  
  # warn about not being installed
  if (!cgal_is_installed() && isFALSE(cgal_pkg_state$WARNED) && !silent) {
    
    packageStartupMessage(warn_mess, domain = NULL, appendLF = TRUE)
    cgal_pkg_state$WARNED <- TRUE
    cgal_pkg_state$VERSION <- NA
  }
  
}


.rcppcgal_package_path <- function() {
  pkg_path = dirname(system.file(".", package = "RcppCGAL"))
  
  return(pkg_path)
}

.cgal_package_path <- function() {
  pkg_path <- .rcppcgal_package_path()
  
  possible_file <- file.path(pkg_path, "include", "CGAL")
  return(possible_file)
}


#' Check if CGAL header files exist in RcppCGAL package
#' 
#' @details
#' This function will perform a very simple check to see if the CGAL folder exists in the include directory and that it is non-empty. If the folder exists and is non-empty, the function returns `TRUE`; otherwise the function returns `FALSE`.
#' 
#'
#' @return logical value
#' @export
#'
#' @examples
#' cgal_is_installed()
cgal_is_installed <- function() {
  # get desired path
  possible_file        <- .cgal_package_path()
  
  # check that folder is present
  CGAL_folder_exists   <- dir.exists(possible_file)
  
  # check that something is there
  CGAL_folder_nonempty <- length(list.files(possible_file)) > 0
  
  # logical flag if both are TRUE
  out <- isTRUE(CGAL_folder_exists && CGAL_folder_nonempty)
  
  return(out)
  
}



