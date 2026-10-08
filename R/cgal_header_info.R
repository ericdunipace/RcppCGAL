#' Report CGAL header information
#'
#' `r lifecycle::badge("deprecated")`
#'
#' `cgal_version()` is deprecated in favor of [cgal_header_info()].
#'
#' @return The value returned by [cgal_header_info()].
#' @export
#'
#' @examples
#' cgal_version()
cgal_version <- function() {
  lifecycle::deprecate_warn("6.x", "cgal_version()", "cgal_header_info()")
  cgal_header_info()
}

#' Report CGAL header information
#'
#' @return Invisibly returns a character string describing the source of the
#' CGAL header files. The same information is also printed as a message.
#' @export
#'
#' @examples
#' cgal_header_info()
cgal_header_info <- function() {
  src <- cgal_pkg_state$HEADER_SOURCE
  message(src)
  invisible(src)
}


#' Return Bundled CGAL Header Version
#'
#' @return Returns ts the default version number of the CGAL header files
#' bundled with the package as a character string
#' @export
#'
#' @examples
#' cgal_bundled_version()
cgal_bundled_version <- function() {
  cgal_pkg_state$BUNDLED_CGAL_VERSION
}
