#' Return CGAL version
#'
#' @return prints the CGAL version of the package
#' @export
cgal_version <- function() {
  
  # pkg_path = dirname(system.file(".", package = "RcppCGAL"))
  # buildnumFile <- file.path(pkg_path, "VERSION")
  # version <- readLines(buildnumFile)
  version <- cgal_pkg_state$VERSION
  message(version)
}

#' Function to write CGAL version
#'
#' @param version Version number or CGAL Path
#' @param own Using own URL or files?
#'
#' @return No return
#'
#' @keywords internal
.save_cgal_version <- function(version, own = FALSE) {
  # pkg_path = dirname(system.file(".", package = "RcppCGAL"))
  
  #save version number
  # buildnumFile <- file.path(pkg_path, "VERSION")
  cgal_pkg_state$OLD_VERSION <- cgal_pkg_state$VERSION
  
  if(!own) {
    # writeLines(text = paste0("This is CGAL version ", version,"\n"), buildnumFile)
    cgal_pkg_state$VERSION <- paste0("This is CGAL version ", version)
  } else {
    # writeLines(text = paste0("Supplied own CGAL from ",version,"\n"), buildnumFile)
    cgal_pkg_stage$VERSION <- paste0("Supplied own CGAL from ", version)
  }
  
}