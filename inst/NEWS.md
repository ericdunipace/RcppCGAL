# Changes in version 5.5.1
CRAN was throwing warnings in Windows versions. Additionally, the automatic download on install threw some problems on cluster computing.

# Changes in version 5.4.1
Clang-14 throws a warning for some bitwise logical operators in "Uncertain.h". I updated the downloader function to change these instances.

# Changes in version 5.4
Updated the package to CGAL v5.4. Caught a bug when replacing CGAL error outputs where it didn't properly include Rcpp. Moved all Rcpp includes to the tops of files to prevent this in the future.

# Changes in version 5.3.1.1 (#issue-1092895079)
Updated the package to edit out references to `std::cerr` and `std::cout` when copying header files. Should prevent error for CRAN checks when attempting to use this package for other R packages on CRAN.

# Changes in version 5.3.1
First release! Header files for CGAL for use in R. Supports CGAL v5.3.1.