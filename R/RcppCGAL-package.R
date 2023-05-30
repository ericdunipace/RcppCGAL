#' @references 
#' The CGAL Project. (2023). {CGAL} User and Reference Manual (5.5.2). Retrieved from <https://doc.cgal.org/5.4/Manual/packages.html>
#' @examples
#' \dontrun{
#' # To use this in a C++ file make sure you add an appropriate
#' # dependency in your header C++ code. Make sure to use CGAL/basic.h
#' 
#' #include <Rcpp.h>
#' // [[Rcpp::depends(RcppCGAL)]]
#' #include <CGAL/basic.h>
#' 
#' // function code
#' 
#' }
"_PACKAGE"

# The following block is used by usethis to automatically manage
# roxygen namespace tags. Modify with care!
## usethis namespace: start
#' @importFrom Rcpp evalCpp
## usethis namespace: end
NULL

# environment to save whether header files have been cleaned
# and best guess of possible version
cgal_pkg_state <- list2env(list(
                        ASK_INSTALL = FALSE,
                        CLEANED = FALSE,
                        OLD_VERSION = NA_character_,
                        VERSION = NA_character_,
                        WARNED = FALSE))