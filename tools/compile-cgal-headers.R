compile_cgal_headers <- function() {
  headers <- c(
    "CGAL/basic.h",
    "CGAL/Cartesian_d.h",
    "CGAL/spatial_sort.h",
    "CGAL/Spatial_sort_traits_adapter_d.h",
    "CGAL/boost/iterator/counting_iterator.hpp",
    "CGAL/hilbert_sort.h"
  )

  for (header in headers) {
    message("Compiling ", header)

    code <- sprintf(
      '
// [[Rcpp::depends(RcppCGAL)]]

#include <Rcpp.h>
#include <%s>

// [[Rcpp::export]]
SEXP rcppcgal_compile_probe() {
    return R_NilValue;
}
',
      header
    )

    Rcpp::sourceCpp(
      code = code,
      rebuild = TRUE,
      showOutput = FALSE,
      verbose = FALSE
    )
  }

  invisible(NULL)
}
