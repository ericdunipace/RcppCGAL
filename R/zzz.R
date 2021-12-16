# downloads CGAL if necessary
.onLoad <- function(libname, pkgname) {
  return(.cgal.downloader())
}

.onAttach <- function(libname, pkgname) {
  packageStartupMessage("For more information about how to use the header files, see the CGAL documentation  at <https://www.cgal.org>.\n
Also, if using this package for commercial purposes, please see <https://www.cgal.org/license.html> for more details about licensing the CGAL header files.", domain = NULL, appendLF = TRUE)
  cgal_version() 
}