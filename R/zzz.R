# downloads CGAL if necessary
.onLoad <- function(libname, pkgname) {
  
  install_cgal <- isTRUE(Sys.getenv("CGAL_DOWNLOAD")  != "0")
  interact     <- interactive()
  # on_cran      <- !identical(Sys.getenv("NOT_CRAN"), "true")
  has_internet <- curl::has_internet()
  no_cgal      <- !cgal_is_installed()
  default_url  <- cgal_pkg_state$DEFAULT_URL
  default_vers <- cgal_pkg_state$DEFAULT_VERSION
  
  if(no_cgal && has_internet && install_cgal && !interact ) {
    # to comply with CRAN, must download a fixed version of files by default.
    # this will check for environment variable otherwise will pass default
    if (Sys.getenv("CGAL_DIR") != "") {
      default_url <- NULL
    }
    
    tryCatch(suppressMessages(cgal_install(cgal_path = default_url)),
             error = .cgal_install_error_catch
             )
    
    if (Sys.getenv("CGAL_DIR") == "") {
      # needs another check currently to save proper version
      .save_cgal_version(version = default_vers, own = FALSE)
    }
    
  }
  
  .cgal_download_check() # will see if interactive and ask to download
  
}

.onAttach <- function(libname, pkgname) {
  
  .cgal_download_check() # will see if interactive and ask to download
  
  packageStartupMessage("For more information about how to use the header files, see the CGAL documentation  at <https://www.cgal.org>. The header files as setup by this package are under a GPL-3 license. For the use of the header files outside this package, please see <https://www.cgal.org/license.html>.\n
Please cite this package if you use it. See citation('RcppCGAL').\n", domain = NULL, appendLF = TRUE)
  
  if ( cgal_is_installed() && !is.na(.cgal_version_check()) ) {
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
