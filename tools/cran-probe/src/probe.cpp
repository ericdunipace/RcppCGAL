#include <Rcpp.h>

#include <CGAL/basic.h>
#include <CGAL/Cartesian_d.h>
#include <CGAL/spatial_sort.h>
#include <CGAL/Spatial_sort_traits_adapter_d.h>
#include <CGAL/hilbert_sort.h>

typedef CGAL::Cartesian_d<double> Kernel;
typedef Kernel::Point_d Point_d;

void rcppcgal_probe()
{
    std::vector<Point_d> points;

    const double x1[] = {0.0, 0.0};
    const double x2[] = {1.0, 1.0};

    points.emplace_back(2, x1, x1 + 2);
    points.emplace_back(2, x2, x2 + 2);

    CGAL::hilbert_sort(points.begin(), points.end());
}