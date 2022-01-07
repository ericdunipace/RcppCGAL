# downloads CGAL if necessary
.onLoad <- function(libname, pkgname) {
  file <- .cgal.downloader()
  # cgal overwrite std::cerr
  .cgal.cerr.remover()
  return(invisible(file))
}

.onAttach <- function(libname, pkgname) {
  packageStartupMessage("For more information about how to use the header files, see the CGAL documentation  at <https://www.cgal.org>.\n
Also, if using this package for commercial purposes, please see <https://www.cgal.org/license.html> for more details about licensing the CGAL header files.", domain = NULL, appendLF = TRUE)
}
