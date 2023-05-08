# downloads CGAL if necessary
.onLoad <- function(libname, pkgname) {
  
  install_cgal_check <- Sys.getenv("CGAL_DOWNLOAD")
  
  if( install_cgal_check == "1") {
    cgal_install(force = TRUE)
  }

  .cgal_exists()
}

.onAttach <- function(libname, pkgname) {
  packageStartupMessage("For more information about how to use the header files, see the CGAL documentation  at <https://www.cgal.org>.\n
Also, if using this package for commercial purposes, please see <https://www.cgal.org/license.html> for more details about licensing the CGAL header files.\n
Please cite this package if you use it. See citation('RcppCGAL').", domain = NULL, appendLF = TRUE)
}
