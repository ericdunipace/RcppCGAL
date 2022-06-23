#' Return CGAL version
#'
#' @return prints the CGAL version of the package
#' @export
cgal_version <- function() {
  message(paste0("If the package autodownloaded the header files, this is CGAL version 5.4.1"))
}