#' Return CGAL version
#'
#' @return prints the CGAL version of the package
#' @export
#' 
#' @examples 
#' cgal_version()
cgal_version <- function() {
  message("This package is bundled with 5.6 but CRAN would not allow this package to record whether you used your own CGAL or not.")
  # vers <- cgal_pkg_state$VERSION
  # if (is.na(vers)) stop("There has been an error where the version was not set. Please report this bug.")
  # message(vers)
}
