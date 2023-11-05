# TODO: Remove/change functions below comment at line 79

# If interactive will ask to DL and then warn if not downloaded
.cgal_download_check <- function(silent = FALSE) {
  interact <- interactive()
  
  # setup warning messages
  warn_mess <- "\nCGAL header files not found on installation. You should run `set_cgal()` and then re-install to make sure they're properly downloaded or transferred from location on your machine on package install."
  
  # add autoinstall errors
  if (.install_error()) {
    warn_mess <- paste0(warn_mess, "Additionally, auto-download attempt generated the following error: \n")
    warn_mess <- paste0(c(warn_mess, .cgal_install_error_read()),
                        collapse = "\n")
  } else {
    warn_mess <- paste0(warn_mess, " \n")
  }
  
  # # run interactive download check
  # if (interact  && !cgal_is_installed() && isFALSE(cgal_pkg_state$ASK_INSTALL) ) { # will ask user if they want to install header files if they are in interactive mode
  #   cgal_pkg_state$ASK_INSTALL <- TRUE
  #   install <- tryCatch(utils::askYesNo("No CGAL header files. Download latest version?"),
  #                       error = function(e) FALSE)
  #   if (!is.na(install) &&  install )  {
  #     cgal_install(cgal_path = cgal_pkg_state$DEFAULT_URL)
  #   } else {
  #     packageStartupMessage(warn_mess, domain = NULL, appendLF = TRUE)
  #     cgal_pkg_state$WARNED <- TRUE
  #   }
  # }
  
  # warn about not being installed
  if (!cgal_is_installed() && isFALSE(cgal_pkg_state$WARNED) && !silent) {
    
    packageStartupMessage(warn_mess, domain = NULL, appendLF = TRUE)
    cgal_pkg_state$WARNED <- TRUE
    cgal_pkg_state$VERSION <- NA
    .delete_cgal_version()
  }
  
}


.rcppcgal_package_path <- function() {
  pkg_path = dirname(system.file(".", package = "RcppCGAL"))
  
  return(pkg_path)
}

.cgal_package_path <- function() {
  pkg_path <- .rcppcgal_package_path()
  
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


#### The following functions should probably be removed and purpose folded into the above if needed

.install_error <- function() {
  pkg_path <- .rcppcgal_package_path()
  errorFile <- file.path(pkg_path, "AUTO_INSTALL_ERROR")
  
  return(file.exists(errorFile))
}

.cgal_install_error_catch <- function(e) {
  pkg_path <- .rcppcgal_package_path()
  errorFile <- file.path(pkg_path, "AUTO_INSTALL_ERROR")
  
  writeLines(text =  paste0(e), errorFile)
}

.cgal_install_error_read <- function(e) {
  pkg_path <- .rcppcgal_package_path()
  errorFile <- file.path(pkg_path, "AUTO_INSTALL_ERROR")
  
  if(file.exists(errorFile)) {
    return(readLines(errorFile) )
  } else {
    return(NULL)
  }
}

.delete_error_file <- function() {
  pkg_path <- .rcppcgal_package_path()
  errorFile <- file.path(pkg_path, "AUTO_INSTALL_ERROR")
  
  if(file.exists(errorFile)) unlink(errorFile) 
}
