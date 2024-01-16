# RcppCGAL (development version)

# Package RcppCGAL

## Changes in 5.6.1

### Minor improvements and Bug Fixes
* Adding Tyler Morgan-Wall to contributors to appropriately reflect patch in last version
* Windows Server 2022 was hanging on the untar stage. Using native R tar on Windows machines seems to fix
* Still using 5.6 version CGAL header files.

## Changes in 5.6.0

### Major updates
* Snafu due to me being busy and not responding to requests for update from CRAN. Package was archived. 
* Update to fix an issue in a dependent package caused my simple checking function replacing a non-standard library exit function in the CGAL header files (Issue #11). User `tylermorganwall` found bug and fixed. Thank you!
* Package now is bundled with a fixed version (5.6.0) of CGAL header files
* Will download from CGAL release 5.6.0 if those files are somehow missing
* User can supply own head files via `CGAL_DIR` as before
* Whether a user supplies their own header files is now no longer recorded due to CRAN objection and them not reading response emails.
* Deprecating the `cgal_install()` function. Had planned to give an error via `lifecycle` package; however, CRAN maintainers are not reading their emails and assume the function is still working. Previously, planned to soft deprecate but CRAN objected.
* Removed dependency on `gh` package

### New features
* added a `set_cgal` function (and `unset_cgal()`) to help users who may have trouble setting the environmental variables on their own.

## Changes in 5.5.3

### Minor improvements and Bug Fixes
* The new CGAL 5.6-beta causing issues for the package. This should now be fixed to favor stable releases over beta releases
* Also tried to make some package messages and errors more informative

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
