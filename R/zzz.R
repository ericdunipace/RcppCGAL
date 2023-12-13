# downloads CGAL if necessary
.onLoad <- function(libname, pkgname) {
  
  install_cgal <- isTRUE(Sys.getenv("CGAL_DOWNLOAD")  != "0")
  interact     <- interactive()
  no_cgal      <- !cgal_is_installed()
  # utils::adist
  
  .cgal_download_check() # will see if header files are found
  
}

.onAttach <- function(libname, pkgname) {
  
  .cgal_download_check() # will see if interactive and ask to download
  
  packageStartupMessage("For more information about how to use the header files, see the CGAL documentation  at <https://www.cgal.org>. The header files as setup by this package are under a GPL-3 license. For the use of the header files outside this package, please see <https://www.cgal.org/license.html>.\n
Please cite this package if you use it. See citation('RcppCGAL').\n", domain = NULL, appendLF = TRUE)
  
  if ( cgal_is_installed() ) {
    packageStartupMessage(cgal_pkg_state$VERSION, domain = NULL, appendLF = TRUE)
  }
  
}


# is_online <- function(site="http://www.google.com/") { #from stackexchange
#   tryCatch({
#     readLines(site,n=1)
#     TRUE
#   },
#   warning = function(w) invokeRestart("muffleWarning"),
#   error = function(e) FALSE)
# }
