.cgal_download_check <- function(silent = FALSE) {
  interact <- interactive()
  if (interact  && !cgal_is_installed() && isFALSE(cgal_pkg_state$ASK_INSTALL) ) { # will ask user if they want to install header files if they are in interactive mode
    cgal_pkg_state$ASK_INSTALL <- TRUE
    install <- tryCatch(utils::askYesNo("No CGAL header files. Download latest version?"),
                        error = function(e) FALSE)
    if (!is.na(install) &&  install )  {
      cgal_install()
    }
  }
  if (interact && !cgal_is_installed() && isFALSE(cgal_pkg_state$WARNED) && !silent) {
    packageStartupMessage("\nCGAL header files not found on installation. You should run `cgal_install()` to make sure they're installed in the package.\n"
                          , domain = NULL, appendLF = TRUE)
    cgal_pkg_state$WARNED <- TRUE
  }
  
  
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