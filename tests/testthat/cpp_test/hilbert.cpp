// [[Rcpp::plugins(cpp14)]]  
// [[Rcpp::depends(RcppCGAL)]]
// [[Rcpp::depends(Rcpp)]]

#include <Rcpp.h>
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
Rcpp::IntegerVector hilbertSort(Rcpp::NumericMatrix & A)
{
  int K = A.rows();
  int N = A.cols();
  std::vector<int> idx(N);
  Rcpp::NumericVector v(K*N);
  
  for(int k = 0; k < K; k++) for (int n = 0; n < N; n++) v(k + n * K) = A(k,n);
  
  hilbert_sort_cgal_fun(v.begin(), K, N, &idx[0] );
  return(Rcpp::wrap(idx));
}

