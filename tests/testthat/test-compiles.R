
# quick test to see if header files are present by compiling code 
# that I know previously worked

testthat::test_that("simple file can compile", {
  Rcpp::sourceCpp(file = "cpp_test/hilbert.cpp")
  
  testthat::expect_true(is.function(hilbertSort))
  
})

testthat::test_that("header files found", {
  testthat::expect_true(RcppCGAL::cgal_is_installed())
})
