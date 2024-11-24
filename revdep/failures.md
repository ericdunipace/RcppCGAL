# approxOT

<details>

* Version: 1.1
* GitHub: https://github.com/ericdunipace/approxOT
* Source code: https://github.com/cran/approxOT
* Date/Publication: 2024-01-16 11:50:02 UTC
* Number of recursive dependencies: 30

Run `revdepcheck::revdep_details(, "approxOT")` for more info

</details>

## Newly broken

*   checking whether package ‘approxOT’ can be installed ... ERROR
    ```
    Installation failed.
    See ‘/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/checks.noindex/approxOT/new/approxOT.Rcheck/00install.out’ for details.
    ```

## Newly fixed

*   checking whether package ‘approxOT’ can be installed ... WARNING
    ```
    Found the following significant warnings:
      sort.cpp:87:35: warning: 'LinSpaced' is deprecated [-Wdeprecated-declarations]
      sort.cpp:109:35: warning: 'LinSpaced' is deprecated [-Wdeprecated-declarations]
      sort.cpp:133:35: warning: 'LinSpaced' is deprecated [-Wdeprecated-declarations]
      sort.cpp:158:32: warning: 'LinSpaced' is deprecated [-Wdeprecated-declarations]
      sort.cpp:223:36: warning: 'LinSpaced' is deprecated [-Wdeprecated-declarations]
      trans_hilbert.cpp:25:25: warning: 'LinSpaced' is deprecated [-Wdeprecated-declarations]
      trans_rank.cpp:29:25: warning: 'LinSpaced' is deprecated [-Wdeprecated-declarations]
      trans_univariate.cpp:21:25: warning: 'LinSpaced' is deprecated [-Wdeprecated-declarations]
      trans_univariate_approx_pwr.cpp:17:22: warning: 'LinSpaced' is deprecated [-Wdeprecated-declarations]
      trans_univariate_approx_pwr.cpp:24:25: warning: 'LinSpaced' is deprecated [-Wdeprecated-declarations]
    See ‘/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/checks.noindex/approxOT/old/approxOT.Rcheck/00install.out’ for details.
    ```

*   checking C++ specification ... NOTE
    ```
      Specified C++14: please drop specification unless essential
    ```

## Installation

### Devel

```
* installing *source* package ‘approxOT’ ...
** package ‘approxOT’ successfully unpacked and MD5 sums checked
** using staged installation
** libs
using C compiler: ‘Apple clang version 16.0.0 (clang-1600.0.26.4)’
using C++ compiler: ‘Apple clang version 16.0.0 (clang-1600.0.26.4)’
using C++14
using SDK: ‘MacOSX15.1.sdk’
clang++ -arch arm64 -std=gnu++14 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/approxOT/Rcpp/include' -I'/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/approxOT/RcppEigen/include' -I'/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/RcppCGAL/new/RcppCGAL/include' -I'/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/approxOT/BH/include' -I/opt/R/arm64/include   -DCGAL_HEADER_ONLY=1 -DCGAL_NO_GMP=1 -I../inst/include -fPIC  -falign-functions=64 -Wall -g -O2   -c RcppExports.cpp -o RcppExports.o
In file included from RcppExports.cpp:4:
...
  281 | class Input_rep<std::optional<T>>
      |                               ^
/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/RcppCGAL/new/RcppCGAL/include/CGAL/IO/io.h:280:17: note: declared here
  280 | template <class T>
      |                 ^
fatal error: too many errors emitted, stopping now [-ferror-limit=]
18 warnings and 20 errors generated.
make: *** [hilbert_cgal.o] Error 1
ERROR: compilation failed for package ‘approxOT’
* removing ‘/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/checks.noindex/approxOT/new/approxOT.Rcheck/approxOT’


```
### CRAN

```
* installing *source* package ‘approxOT’ ...
** package ‘approxOT’ successfully unpacked and MD5 sums checked
** using staged installation
** libs
using C compiler: ‘Apple clang version 16.0.0 (clang-1600.0.26.4)’
using C++ compiler: ‘Apple clang version 16.0.0 (clang-1600.0.26.4)’
using C++14
using SDK: ‘MacOSX15.1.sdk’
clang++ -arch arm64 -std=gnu++14 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/approxOT/Rcpp/include' -I'/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/approxOT/RcppEigen/include' -I'/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/RcppCGAL/old/RcppCGAL/include' -I'/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/approxOT/BH/include' -I/opt/R/arm64/include   -DCGAL_HEADER_ONLY=1 -DCGAL_NO_GMP=1 -I../inst/include -fPIC  -falign-functions=64 -Wall -g -O2   -c RcppExports.cpp -o RcppExports.o
In file included from RcppExports.cpp:4:
...
** inst
** byte-compile and prepare package for lazy loading
** help
*** installing help indices
** building package indices
** testing if installed package can be loaded from temporary location
** checking absolute paths in shared objects and dynamic libraries
** testing if installed package can be loaded from final location
** testing if installed package keeps a record of temporary installation path
* DONE (approxOT)


```
# interpolation

<details>

* Version: 0.1.1
* GitHub: https://github.com/stla/interpolation
* Source code: https://github.com/cran/interpolation
* Date/Publication: 2023-12-20 09:20:02 UTC
* Number of recursive dependencies: 3

Run `revdepcheck::revdep_details(, "interpolation")` for more info

</details>

## Newly broken

*   checking whether package ‘interpolation’ can be installed ... ERROR
    ```
    Installation failed.
    See ‘/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/checks.noindex/interpolation/new/interpolation.Rcheck/00install.out’ for details.
    ```

## Installation

### Devel

```
* installing *source* package ‘interpolation’ ...
** package ‘interpolation’ successfully unpacked and MD5 sums checked
** using staged installation
** libs
using C++ compiler: ‘Apple clang version 16.0.0 (clang-1600.0.26.4)’
using C++17
using SDK: ‘MacOSX15.1.sdk’
clang++ -arch arm64 -std=gnu++17 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/interpolation/Rcpp/include' -I'/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/RcppCGAL/new/RcppCGAL/include' -I'/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/interpolation/BH/include' -I/opt/R/arm64/include   -DCGAL_HEADER_ONLY=1 -I/opt/homebrew/Cellar/gmp/6.3.0/include -fPIC  -g -O3 -mtune=native -arch arm64 -ftemplate-depth-256 -DSTAN_THREADS  -c RcppExports.cpp -o RcppExports.o
In file included from RcppExports.cpp:4:
In file included from ./interpolation_types.h:5:
...
  119 |    explicit BOOST_MP_FORCEINLINE BOOST_MP_CXX14_CONSTEXPR number(const V& v, typename std::enable_if<
      |                                                           ^
/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/interpolation/BH/include/boost/multiprecision/number.hpp:126:44: note: candidate constructor [with V = long]
  126 |    explicit BOOST_MP_FORCEINLINE constexpr number(const V& v, typename std::enable_if<
      |                                            ^
fatal error: too many errors emitted, stopping now [-ferror-limit=]
20 errors generated.
make: *** [RcppExports.o] Error 1
ERROR: compilation failed for package ‘interpolation’
* removing ‘/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/checks.noindex/interpolation/new/interpolation.Rcheck/interpolation’


```
### CRAN

```
* installing *source* package ‘interpolation’ ...
** package ‘interpolation’ successfully unpacked and MD5 sums checked
** using staged installation
** libs
using C++ compiler: ‘Apple clang version 16.0.0 (clang-1600.0.26.4)’
using C++17
using SDK: ‘MacOSX15.1.sdk’
clang++ -arch arm64 -std=gnu++17 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/interpolation/Rcpp/include' -I'/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/RcppCGAL/old/RcppCGAL/include' -I'/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/interpolation/BH/include' -I/opt/R/arm64/include   -DCGAL_HEADER_ONLY=1 -I/opt/homebrew/Cellar/gmp/6.3.0/include -fPIC  -g -O3 -mtune=native -arch arm64 -ftemplate-depth-256 -DSTAN_THREADS  -c RcppExports.cpp -o RcppExports.o
clang++ -arch arm64 -std=gnu++17 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/interpolation/Rcpp/include' -I'/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/RcppCGAL/old/RcppCGAL/include' -I'/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/interpolation/BH/include' -I/opt/R/arm64/include   -DCGAL_HEADER_ONLY=1 -I/opt/homebrew/Cellar/gmp/6.3.0/include -fPIC  -g -O3 -mtune=native -arch arm64 -ftemplate-depth-256 -DSTAN_THREADS  -c interpolation.cpp -o interpolation.o
clang++ -arch arm64 -std=gnu++17 -dynamiclib -Wl,-headerpad_max_install_names -undefined dynamic_lookup -L/Library/Frameworks/R.framework/Resources/lib -L/opt/R/arm64/lib -o interpolation.so RcppExports.o interpolation.o -L/opt/homebrew/Cellar/gmp/6.3.0/lib -lgmp -F/Library/Frameworks/R.framework/.. -framework R -Wl,-framework -Wl,CoreFoundation
...
** R
** byte-compile and prepare package for lazy loading
** help
*** installing help indices
** building package indices
** testing if installed package can be loaded from temporary location
** checking absolute paths in shared objects and dynamic libraries
** testing if installed package can be loaded from final location
** testing if installed package keeps a record of temporary installation path
* DONE (interpolation)


```
# WpProj

<details>

* Version: 0.2
* GitHub: NA
* Source code: https://github.com/cran/WpProj
* Date/Publication: 2024-01-22 17:12:47 UTC
* Number of recursive dependencies: 99

Run `revdepcheck::revdep_details(, "WpProj")` for more info

</details>

## Newly broken

*   checking whether package ‘WpProj’ can be installed ... ERROR
    ```
    Installation failed.
    See ‘/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/checks.noindex/WpProj/new/WpProj.Rcheck/00install.out’ for details.
    ```

## Newly fixed

*   checking tests ...
    ```
      Running ‘spelling.R’
      Running ‘testthat.R’
     ERROR
    Running the tests in ‘tests/testthat.R’ failed.
    Last 13 lines of output:
       9.             └─value[[3L]](cond)
      ── Error ('test-WInftyL1.R:234:5'): WInfL1 changes penalty appropriately for net penalties ──
      Error in `beta[g_index] <- x[g_index] * thresh`: replacement has length zero
      Backtrace:
          ▆
    ...
       1. └─WpProj:::WInfL1(...) at test-WInftyL1.R:234:5
       2.   ├─base::do.call("GroupLambda", GL_args)
       3.   └─WpProj:::GroupLambda(...)
       4.     └─WpProj:::lp_norm(...)
       5.       └─WpProj:::lp_solve(...)
       6.         └─WpProj:::group_threshold(...)
      
      [ FAIL 3 | WARN 3 | SKIP 17 | PASS 869 ]
      Error: Test failures
      Execution halted
    ```

*   checking whether package ‘WpProj’ can be installed ... WARNING
    ```
    Found the following significant warnings:
      SufficientStatistics.cpp:115:25: warning: 'LinSpaced' is deprecated [-Wdeprecated-declarations]
      SufficientStatistics.cpp:116:25: warning: 'LinSpaced' is deprecated [-Wdeprecated-declarations]
      sort.cpp:87:35: warning: 'LinSpaced' is deprecated [-Wdeprecated-declarations]
      sort.cpp:109:35: warning: 'LinSpaced' is deprecated [-Wdeprecated-declarations]
      sort.cpp:133:35: warning: 'LinSpaced' is deprecated [-Wdeprecated-declarations]
      sort.cpp:158:32: warning: 'LinSpaced' is deprecated [-Wdeprecated-declarations]
      sort.cpp:223:36: warning: 'LinSpaced' is deprecated [-Wdeprecated-declarations]
      trans_hilbert.cpp:25:25: warning: 'LinSpaced' is deprecated [-Wdeprecated-declarations]
      trans_rank.cpp:29:25: warning: 'LinSpaced' is deprecated [-Wdeprecated-declarations]
      trans_univariate.cpp:21:25: warning: 'LinSpaced' is deprecated [-Wdeprecated-declarations]
      trans_univariate_approx_pwr.cpp:17:22: warning: 'LinSpaced' is deprecated [-Wdeprecated-declarations]
      trans_univariate_approx_pwr.cpp:24:25: warning: 'LinSpaced' is deprecated [-Wdeprecated-declarations]
    See ‘/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/checks.noindex/WpProj/old/WpProj.Rcheck/00install.out’ for details.
    ```

*   checking C++ specification ... NOTE
    ```
      Specified C++14: please drop specification unless essential
    ```

## Installation

### Devel

```
* installing *source* package ‘WpProj’ ...
** package ‘WpProj’ successfully unpacked and MD5 sums checked
** using staged installation
** libs
using C compiler: ‘Apple clang version 16.0.0 (clang-1600.0.26.4)’
using C++ compiler: ‘Apple clang version 16.0.0 (clang-1600.0.26.4)’
using C++14
using SDK: ‘MacOSX15.1.sdk’
clang++ -arch arm64 -std=gnu++14 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/WpProj/BH/include' -I'/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/WpProj/Rcpp/include' -I'/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/WpProj/RcppEigen/include' -I'/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/WpProj/RcppProgress/include' -I'/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/RcppCGAL/new/RcppCGAL/include' -I'/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/WpProj/RSpectra/include' -I/opt/R/arm64/include    -fPIC  -falign-functions=64 -Wall -g -O2   -c RcppExports.cpp -o RcppExports.o
In file included from RcppExports.cpp:4:
...
  281 | class Input_rep<std::optional<T>>
      |                               ^
/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/RcppCGAL/new/RcppCGAL/include/CGAL/IO/io.h:280:17: note: declared here
  280 | template <class T>
      |                 ^
fatal error: too many errors emitted, stopping now [-ferror-limit=]
23 warnings and 20 errors generated.
make: *** [SufficientStatistics.o] Error 1
ERROR: compilation failed for package ‘WpProj’
* removing ‘/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/checks.noindex/WpProj/new/WpProj.Rcheck/WpProj’


```
### CRAN

```
* installing *source* package ‘WpProj’ ...
** package ‘WpProj’ successfully unpacked and MD5 sums checked
** using staged installation
** libs
using C compiler: ‘Apple clang version 16.0.0 (clang-1600.0.26.4)’
using C++ compiler: ‘Apple clang version 16.0.0 (clang-1600.0.26.4)’
using C++14
using SDK: ‘MacOSX15.1.sdk’
clang++ -arch arm64 -std=gnu++14 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/WpProj/BH/include' -I'/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/WpProj/Rcpp/include' -I'/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/WpProj/RcppEigen/include' -I'/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/WpProj/RcppProgress/include' -I'/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/RcppCGAL/old/RcppCGAL/include' -I'/Users/eifer/GoogleDrive/R/RcppCGAL/revdep/library.noindex/WpProj/RSpectra/include' -I/opt/R/arm64/include    -fPIC  -falign-functions=64 -Wall -g -O2   -c RcppExports.cpp -o RcppExports.o
In file included from RcppExports.cpp:4:
...
** byte-compile and prepare package for lazy loading
** help
*** installing help indices
*** copying figures
** building package indices
** testing if installed package can be loaded from temporary location
** checking absolute paths in shared objects and dynamic libraries
** testing if installed package can be loaded from final location
** testing if installed package keeps a record of temporary installation path
* DONE (WpProj)


```
