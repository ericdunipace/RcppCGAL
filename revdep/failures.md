# interpolation (0.1.1)

* GitHub: <https://github.com/stla/interpolation>
* Email: <mailto:laurent_step@outlook.fr>
* GitHub mirror: <https://github.com/cran/interpolation>

Run `revdepcheck::revdep_details(, "interpolation")` for more info

## In both

*   checking whether package ‘interpolation’ can be installed ... ERROR
     ```
     Installation failed.
     See ‘/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/checks.noindex/interpolation/new/interpolation.Rcheck/00install.out’ for details.
     ```

## Installation

### Devel

```
* installing *source* package ‘interpolation’ ...
** this is package ‘interpolation’ version ‘0.1.1’
** package ‘interpolation’ successfully unpacked and MD5 sums checked
** using staged installation
** libs
using C++ compiler: ‘Apple clang version 17.0.0 (clang-1700.3.19.1)’
using C++17
using SDK: ‘MacOSX26.0.sdk’
clang++ -arch arm64 -std=gnu++17 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/RcppCGAL/new/Rcpp/include' -I'/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/RcppCGAL/new/RcppCGAL/include' -I'/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/interpolation/BH/include' -I/opt/R/arm64/include   -DCGAL_HEADER_ONLY=1 -I/opt/homebrew/Cellar/gmp/6.3.0/include -fPIC  -g -O3 -march=native -arch arm64 -ftemplate-depth-256 -DSTAN_THREADS  -c RcppExports.cpp -o RcppExports.o
In file included from RcppExports.cpp:4:
...
  168 |   return ceilLg(BigInt(a));
      |                        ^
/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/interpolation/BH/include/boost/multiprecision/fwd.hpp:106:17: note: forward declaration of 'boost::multiprecision::backends::gmp_int'
  106 |          struct gmp_int;
      |                 ^
fatal error: too many errors emitted, stopping now [-ferror-limit=]
20 errors generated.
make: *** [RcppExports.o] Error 1
ERROR: compilation failed for package ‘interpolation’
* removing ‘/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/checks.noindex/interpolation/new/interpolation.Rcheck/interpolation’


```
### CRAN

```
* installing *source* package ‘interpolation’ ...
** this is package ‘interpolation’ version ‘0.1.1’
** package ‘interpolation’ successfully unpacked and MD5 sums checked
** using staged installation
** libs
using C++ compiler: ‘Apple clang version 17.0.0 (clang-1700.3.19.1)’
using C++17
using SDK: ‘MacOSX26.0.sdk’
clang++ -arch arm64 -std=gnu++17 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/interpolation/Rcpp/include' -I'/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/RcppCGAL/old/RcppCGAL/include' -I'/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/interpolation/BH/include' -I/opt/R/arm64/include   -DCGAL_HEADER_ONLY=1 -I/opt/homebrew/Cellar/gmp/6.3.0/include -fPIC  -g -O3 -march=native -arch arm64 -ftemplate-depth-256 -DSTAN_THREADS  -c RcppExports.cpp -o RcppExports.o
In file included from RcppExports.cpp:4:
...
  168 |   return ceilLg(BigInt(a));
      |                        ^
/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/interpolation/BH/include/boost/multiprecision/fwd.hpp:106:17: note: forward declaration of 'boost::multiprecision::backends::gmp_int'
  106 |          struct gmp_int;
      |                 ^
fatal error: too many errors emitted, stopping now [-ferror-limit=]
20 errors generated.
make: *** [RcppExports.o] Error 1
ERROR: compilation failed for package ‘interpolation’
* removing ‘/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/checks.noindex/interpolation/old/interpolation.Rcheck/interpolation’


```
