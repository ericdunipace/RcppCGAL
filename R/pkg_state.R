# environment to save whether header files have been cleaned
# VERSION populated with version from package or user supplied (due to CRAN preference, this is not currently done)
cgal_pkg_state <- list2env(list(
  VERSION = 'This package is bundled with CGAL version 5.6.',
  WARNED = FALSE))
