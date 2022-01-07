<!-- badges: start -->
[![R-CMD-check](https://github.com/ericdunipace/RcppCGAL/workflows/R-CMD-check/badge.svg)](https://github.com/ericdunipace/RcppCGAL/actions)
<!-- badges: end -->
## RcppCGAL: CGAL Headers for R


### Description

This package provides access to the Computational Geometry Algorithms Library ([CGAL](https://www.cgal.org)) in [R](https://www.r-project.org).  [CGAL](https://www.cgal.org) provides access to methods like KDtree, Hilbert sorting, convex hull calculation, and many more.

This package allows for the easy linking of the CGAL header files into R packages without having to download and manually add the appropriate CGAL header file into an R package.

Much like the `BH` package, the `RcppCGAL` package can be used via the `LinkingTo:` field in the `DESCRIPTION` file in R packages. This will allow access to the header files in C/C++ source code.

### Version
This package currently includes the version 5.3.1 stable release of CGAL.

### Installation
To install this package, you can install the version from CRAN:
```R
install.packages("RcppCGAL")
```

Alternatively, you can download or clone the git repository. Then you can install using devtools
```R
devtools::install("RcppCGAL")
```
You may also install from github directly using the
`devtools::install_github` function.

By default, the package will try to download the header files from the
CGAL git repository. If you already have one downloaded that you prefer to use,
you can specify the environmental variable `CGAL_DIR` and `R` will use that
instead:
```R
Sys.setenv("CGAL_DIR" = "path/to/CGAL/include")
```
Note: this must be done *before* the package is loaded by `R`.

### Example
We provide an example of how to perform Hilbert sorting using an R matrix:

```c++
// [[Rcpp::depends(RcppCGAL)]]
// [[Rcpp::depends(RcppEigen)]]
// [[Rcpp::plugins(cpp14)]]  

#include <RcppEigen.h>
#include <CGAL/basic.h>
#include <CGAL/Cartesian_d.h>
#include <CGAL/spatial_sort.h>
#include <CGAL/Spatial_sort_traits_adapter_d.h>
#include <CGAL/boost/iterator/counting_iterator.hpp>
#include <CGAL/hilbert_sort.h>
#include <CGAL/Spatial_sort_traits_adapter_d.h>

typedef CGAL::Cartesian_d<double>           Kernel;
typedef Kernel::Point_d                     Point_d;

typedef CGAL::Spatial_sort_traits_adapter_d<Kernel, Point_d*>   Search_traits_d;

void hilbert_sort_cgal_fun(const double * A, int D, int N,  int * idx)
{

  std::vector<Point_d> v;
  double * temp = new double[D];

  for (int n = 0; n < N; n++ ) {
    for (int d = 0; d < D; d ++) {
      temp[d] = A[D * n + d];
    }
    v.push_back(Point_d(D, temp, temp+D));
  }

  std::vector<std::ptrdiff_t> temp_index;
  temp_index.reserve(v.size());

  std::copy(
    boost::counting_iterator<std::ptrdiff_t>(0),
    boost::counting_iterator<std::ptrdiff_t>(v.size()),
    std::back_inserter(temp_index) );

  CGAL::hilbert_sort (temp_index.begin(), temp_index.end(), Search_traits_d( &(v[0]) ) ) ;

  for (int n = 0; n < N; n++) {
    idx[n] = temp_index[n];
  }

  delete [] temp;
  temp=NULL;
}

// [[Rcpp::export]]
Rcpp::IntegerVector hilbertSort(const Eigen::MatrixXd & A)
{
  int K = A.rows();
  int N = A.cols();
  std::vector<int> idx(N);
  
  hilbert_sort_cgal_fun(A.data(), K, N, &idx[0] );
  return(Rcpp::wrap(idx));
}
```

Saving this code as `hilbertSort.cpp` and sourcing with Rcpp `Rcpp::sourceCpp("hilbertSort.cpp")`
makes the function `hilbertSort()`. Note that version 5.3.1
relies on the C++14 standard. Also, be aware that this example 
function example assumes that the observations are stored by
column rather than by row, that is as the transpose of the 
usual `R` `matrix` or `data.frame`.

### Author

Eric Dunipace

## License
This package is provided under the GPL v3+. Note: if you wish to use CGAL for commercial purposes, you must obtain a license from
the [GeometryFactory](https://geometryfactory.com).

