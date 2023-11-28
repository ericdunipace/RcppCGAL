#' Return CGAL version
#'
#' @return prints the CGAL version of the package
#' @export
#' 
#' @examples 
#' cgal_version()
cgal_version <- function() {
  message("Due to CRAN not responding to emails or perusing submission documents, whether you used your own CGAL or not is no longer recorded. This package is bundled with 5.6 but who knows what's gone on!?")
  # vers <- cgal_pkg_state$VERSION
  # if (is.na(vers)) stop("There has been an error where the version was not set. Please report this bug.")
  # message(vers)
}
