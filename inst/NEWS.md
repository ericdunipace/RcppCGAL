# Package RcppCGAL

## Changes in 5.5.2.9000

## Changes in 5.5.2

### New features
* Added a new feature to automatically find the latest GitHub release (currently 5.5.2). Unfortunately, this requires an additional import: the `gh` package.
* Users will also have to use the new `cgal_install()` function to download the header files AFTER installation. This can be circumvented via some environmental options as listed in the installation vignette
* There's now an installation vignette!
* Made the cleaning up of the calls to `std::cerr` optional with default to clean them up. See documentation for `cgal_install()`.

### Minor improvements and Bug Fixes
* CRAN was throwing warnings in Windows versions. New update might fix.
* Additionally, the automatic download on install threw some problems on cluster computing. Should be fixed now (#)
* `cgal_version()` will now display the guessed version from GitHub OR the file/url path used to download/install the headerfiles.
* version number, as always, aligns with latest CGAL version.

## Changes in 5.4.1
Clang-14 throws a warning for some bitwise logical operators in "Uncertain.h". I updated the downloader function to change these instances.

## Changes in 5.4
Updated the package to CGAL v5.4. Caught a bug when replacing CGAL error outputs where it didn't properly include Rcpp. Moved all Rcpp includes to the tops of files to prevent this in the future.

## Changes in 5.3.1.1 
Updated the package to edit out references to `std::cerr` and `std::cout` when copying header files. Should prevent error for CRAN checks when attempting to use this package for other R packages on CRAN (#issue-1092895079).

## Changes in 5.3.1
First release! Header files for CGAL for use in R. Supports CGAL v5.3.1.