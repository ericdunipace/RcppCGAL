#' Return CGAL version
#'
#' @return prints the CGAL version of the package
#' @export
cgal_version <- function() {
  pkg_path = dirname(system.file(".", package = "RcppCGAL"))
  buildnumFile <- file.path(pkg_path, "VERSION")
  version <- readLines(buildnumFile)
  
  cat(paste0("CGAL version ",version))
}