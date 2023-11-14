# TODO: removed downloader functions to the configure stage. Remove functions below set_cgal once cgal_install removed.

#' Set the CGAL header file directory
#'
#' @param path character vector. either a URL or system path
#'
#' @description
#' This package will set the `CGAL_DIR` environmental variable if you don't know how. Then you can re-install the `RcppCGAL` package and the installation should use your preferred source of the CGAL library. Note the cleaner functions will run automatically and replace the calls to std::err and exit in the C code. They have been tested on CGAL 5.6 so are not guaranteed to work with other versions of the CGAL headers.
#' 
#'
#' @return Invisibley returns TRUE if the `CGAL_DIR` variable was successfully set or or FALSE if it was not.
#' 
#' @seealso [unset_cgal()]
#' 
#' @export
#'
#' @examples
#' \dontrun{
#' # set_cgal("path/to/include/CGAL")
#' }
set_cgal <- function(path) {
  
  Sys.setenv("CGAL_DIR" = path)
}

#' Unset the CGAL header file directory
#'
#' @param ... Not used at this time
#'
#' @description
#' This package will remove the `CGAL_DIR` environmental variable.
#' 
#'
#' @return Invisibley returns TRUE if the `CGAL_DIR` variable was successfully removed or or FALSE if it was not.
#' 
#' @seealso [unset_cgal()]
#' 
#' @export
#'
#' @examples
#' \dontrun{
#' # unset_cgal()
#' }
unset_cgal <- function(...) {
  
  Sys.unsetenv("CGAL_DIR")
}

#' CGAL header file installer
#' 
#' @description
#' `r lifecycle::badge("deprecated")`
#' This function previously installed or updated the CGAL header files. It has been hard deprecated instead of soft deprecated due to CRAN request. 
#' 
#'
#' @param cgal_path Path to CGAL files on your machine, a URL. If NULL will downloaded latest version from GitHub. Default is NULL.
#' @param version Desired version to search for from the GitHub. If NULL, will download latest.
#' @param clean_files Whether to remove calls to C std::err from header files to avoid errors in R. Default is TRUE
#' @param force Whether to force downloading and install the header files if they're already found in the package. Default is FALSE
#'
#' @return NULL
#' 
#' @export
#' 
cgal_install <- function(cgal_path = NULL, version = NULL, clean_files = TRUE, force = FALSE) {
  
  #deprecation error
  lifecycle::deprecate_stop(
    when = "5.6.0",
    what = "cgal_install()",
    details = "Please use the function `set_cgal()` instead to install your desired version of the CGAL  header files. `cgal_install()` is no longer supported due to CRAN policy."
  )
}

