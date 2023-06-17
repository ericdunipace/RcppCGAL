#' Return CGAL version
#'
#' @return prints the CGAL version of the package
#' @export
cgal_version <- function() {
  
  vers <- .cgal_version_check()
  if (is.na(vers)) vers <- "Version not set yet. Likely you need to download the header files with cgal_install()."
  message(vers)
}

.cgal_version_check <- function() {
  vers <- cgal_pkg_state$VERSION
  if (is.na(vers)) {
    pkg_path <- .rcppcgal_package_path()
    buildnumFile <- file.path(pkg_path, "VERSION")
    
    # only update version variable if file exists
    if (file.exists(buildnumFile)) {
      vers <- readLines(buildnumFile)
      cgal_pkg_state$VERSION <- vers
    } 
    
  }
  return(cgal_pkg_state$VERSION)
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
  
  # save old version
  cgal_pkg_state$OLD_VERSION <- cgal_pkg_state$VERSION
  
  # create environmental variable
  if(!own) {
    cgal_pkg_state$VERSION <- paste0("This is CGAL version ", version)
  } else {
    cgal_pkg_state$VERSION <- paste0("Supplied own CGAL from ", version)
  }
  
  #save version number
  pkg_path <- .rcppcgal_package_path()
  buildnumFile <- file.path(pkg_path, "VERSION")
  writeLines(text =  cgal_pkg_state$VERSION, buildnumFile)
}