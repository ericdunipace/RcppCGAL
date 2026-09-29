#ifndef RCPPCGAL_COMPAT_H
#define RCPPCGAL_COMPAT_H

#if !defined(CGAL_USE_GMP) && \
    !defined(CGAL_NO_GMP) && \
    !defined(CGAL_DISABLE_GMP)
# define CGAL_NO_GMP 1
# define CGAL_DISABLE_GMP 1
#endif

#include <Rcpp.h>
#include <R_ext/Random.h>
#include <cstddef>
#include <stdexcept>

namespace RcppCGAL {

inline double RCGAL_unif_rand() {
    Rcpp::RNGScope scope;
    return unif_rand();
}

inline std::size_t RCGAL_unif_index(std::size_t size) {
    if (size == 0)
        throw std::invalid_argument("Cannot sample from an empty range");

    Rcpp::RNGScope scope;
    return static_cast<std::size_t>(
        R_unif_index(static_cast<double>(size))
    );
}

} // namespace RcppCGAL

#endif
