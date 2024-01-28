test_that("cgal present", {
  testthat::expect_true(RcppCGAL::cgal_is_installed())
})

# testthat::test_that("cgal compiles", {
#   Rcpp::sourceCpp(file = "cpp/cgal_test_fun.cpp")  
#   testthat::expect_true(cgal_test_())
# })
