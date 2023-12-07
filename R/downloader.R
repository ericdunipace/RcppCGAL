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
#' set_cgal("path/to/include/CGAL")
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
#' unset_cgal()
#' }
unset_cgal <- function(...) {
  
  Sys.unsetenv("CGAL_DIR")
}


