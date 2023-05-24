# downloads CGAL if necessary
.onLoad <- function(libname, pkgname) {
  
  install_cgal_check <- Sys.getenv("CGAL_DOWNLOAD")
  not_interact <- interactive()
  on_cran <- !identical(Sys.getenv("NOT_CRAN"), "true")
  
  if( install_cgal_check == "1" #|| (not_interact && on_cran)
      ) {
    cgal_install(clean_files = TRUE, force = TRUE)
  }

}

.onAttach <- function(libname, pkgname) {
  if ( interactive() ) { # will ask user if they want to install header files if they are in interactive mode
    if (!cgal_is_installed()) {
      install <- tryCatch(utils::askYesNo("No CGAL header files. Download latest version?"),
                          error = function(e) FALSE)
      if (!is.na(install) &&  install )  {
        cgal_install()
      } else {
        packageStartupMessage("CGAL header files are not installed. To download use the `cgal_install()` function.", domain = NULL, appendLF = TRUE)
      }
    }
  } else {
    if (!cgal_is_installed()) {
      packageStartupMessage("\nCGAL header files not found on installation. You should run `cgal_install()` to make sure they're installed in the package"
                            , domain = NULL, appendLF = TRUE)
    }
  }
  
  packageStartupMessage("For more information about how to use the header files, see the CGAL documentation  at <https://www.cgal.org>.\n
Also, if using this package for commercial purposes, please see <https://www.cgal.org/license.html> for more details about licensing the CGAL header files.\n
Please cite this package if you use it. See citation('RcppCGAL').", domain = NULL, appendLF = TRUE)
  
}
