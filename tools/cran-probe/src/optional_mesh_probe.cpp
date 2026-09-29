#include <Rcpp.h>
#include <CGAL/Simple_cartesian.h>
#include <CGAL/Surface_mesh.h>
#include <CGAL/Polygon_mesh_processing/repair_polygon_soup.h>
#include <CGAL/Surface_mesh_simplification/Policies/Edge_collapse/GarlandHeckbert_plane_policies.h>

#include <cstddef>
#include <vector>

// Instantiating these templates catches errors that merely including the
// headers cannot detect. Eigen is supplied by this CI-only probe package.
void rcppcgal_optional_mesh_probe()
{
    using Kernel = CGAL::Simple_cartesian<double>;
    using Point = Kernel::Point_3;
    using Mesh = CGAL::Surface_mesh<Point>;

    std::vector<Point> points{Point(0.0, 0.0, 0.0)};
    std::vector<std::size_t> polygon{0};
    bool reversed = true;
    auto canonical =
        CGAL::Polygon_mesh_processing::internal::construct_canonical_polygon(
            points, polygon, reversed, Kernel());
    (void) canonical;

    Mesh mesh;
    CGAL::Surface_mesh_simplification::
        GarlandHeckbert_plane_policies<Mesh, Kernel> policy(mesh);
    (void) policy;
}
