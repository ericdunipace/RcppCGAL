# Contributing to RcppCGAL

Submit changes to the header patch code and relevant tests against `dev`.
Contributors do not need to build or commit `inst/include/CGAL_zip.tar.xz`;
leave the committed archive out of your PR to avoid binary merge conflicts.

After merge, the bot regenerates and commits changed headers when checks pass,
then starts another run to check the committed bundle.
