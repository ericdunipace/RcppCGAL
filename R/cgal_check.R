.cgal_exists <- function(silent = FALSE) {
  exists <- cgal_is_installed()
  
  if (!exists) {
    if(!silent) return("\nCGAL header files not found on installation. You should run `cgal_install()` to make sure they're installed in the package")
  }
  
  return(invisible(exists))
  
  
}

.cgal_package_path <- function() {
  pkg_path = dirname(system.file(".", package = "RcppCGAL"))
  
  possible_file <- file.path(pkg_path, "include", "CGAL")
  return(possible_file)
}


#' Check if CGAL header files exist in RcppCGAL package
#'
#' @return logical value
#' @export
#'
#' @examples
#' cgal_is_installed()
cgal_is_installed <- function() {
  possible_file <- .cgal_package_path()
  
  out <- if (!file.exists(possible_file)) {
    FALSE
  } else {
    TRUE
  }
  
  return(out)
  
}