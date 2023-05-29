# downloads CGAL if necessary
.onLoad <- function(libname, pkgname) {
  
  install_cgal <- isTRUE(Sys.getenv("CGAL_DOWNLOAD")  != "0")
  interact     <- interactive()
  # on_cran      <- !identical(Sys.getenv("NOT_CRAN"), "true")
  has_internet <- curl::has_internet()
  no_cgal      <- !cgal_is_installed()
  
  if(no_cgal && has_internet && install_cgal && !interact ) {
    tryCatch(cgal_install(),
             error = function(e) {NULL},
             warning = function(w){NULL})
  }
  
  .cgal_download_check() # will see if interactive and ask to download
  
}

.onAttach <- function(libname, pkgname) {
  
  .cgal_download_check() # will see if interactive and ask to download
  
  packageStartupMessage("For more information about how to use the header files, see the CGAL documentation  at <https://www.cgal.org>.\n
Also, if using this package for commercial purposes, please see <https://www.cgal.org/license.html> for more details about licensing the CGAL header files.\n
Please cite this package if you use it. See citation('RcppCGAL').", domain = NULL, appendLF = TRUE)
  
}


# is_online <- function(site="http://www.google.com/") { #from stackexchange
#   tryCatch({
#     readLines(site,n=1)
#     TRUE
#   },
#   warning = function(w) invokeRestart("muffleWarning"),
#   error = function(e) FALSE)
# }
