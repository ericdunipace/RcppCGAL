# Contributing to RcppCGAL

Submit changes to the header patch code and relevant tests against `dev`.
Contributors do not need to build or commit `inst/include/CGAL_zip.tar.xz`;
leave the committed archive out of your PR to avoid binary merge conflicts.

PR CI downloads pristine CGAL, applies the PR's patch code, generates a temporary
bundle, and runs package and downstream checks against it. It never commits
anything to a PR branch.

After merging to `dev` or `main`, CI repeats the build and checks. If all
rebuilt-bundle checks pass and header contents changed, GitHub Actions commits
only the regenerated archive to that branch. Archive metadata alone does not
cause a commit. Maintainers can also dispatch the rebuild workflow on those branches.

The separate shipped-bundle check examines the currently committed archive.
It may report stale-header failures while a successful rebuilt candidate is
awaiting its automatic commit; it does not block that commit. Installation must
still preserve bundled header contents. Apply header fixes during generation;
downloaded or user-supplied CGAL may be patched in its own installation path.

Automatic commits use the repository-scoped `GITHUB_TOKEN`, with write
permission granted only to the commit job. No personal access token is needed.
The token's push does not start another workflow run; the committed archive is
the artifact that just passed the rebuilt-bundle checks.

Maintainers should use read-only default workflow permissions. If branch
protection prevents the bot's push, configure an allowed bypass or use a
separate bundle-update PR process. Push failures caused by protection or
permissions are reported as errors.
