.cgal_exists <- function(silent = FALSE) {
  pkg_path = dirname(system.file(".", package = "RcppCGAL"))
  
  possible_file <- file.path(pkg_path, "include", "CGAL")
  
  if (!file.exists(possible_file)) {
    if(!silent) warning("CGAL header files not found on installation. You should run `cgal_install()` to make sure they're installed in the package", call. = FALSE)
    return (FALSE)
  } else {
    return (TRUE)
  }
  
}