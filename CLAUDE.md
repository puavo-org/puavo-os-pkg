# Working with Claude in this repository

## Updating a package's upstream version

When asked to "update `<package>`" (e.g. "update vscode"), that means running
the full package-update procedure below end to end, not just checking for a
new version or editing a single file:

1. Find the vendor's current stable download URL for that package, resolving
   any redirect to the concrete, versioned URL. Pin the immutable URL here,
   not one that keeps redirecting to whatever is newest.
2. Download it and compute its `sha384sum`.
3. Write the URL and checksum into that package's `upstream_pack_url` and
   `upstream_pack_sha384sum` files.
4. Check the package's `rules` file against the new upstream pack (e.g. list
   a `.deb` with `dpkg-deb -c`): every path that `rules` symlinks, copies,
   chmods or otherwise uses inside the unpacked upstream directory must
   still exist. Vendors sometimes rename files (VS Code 1.140.0 renamed
   `code.desktop` to `com.microsoft.VSCode.desktop`), and `ln -fns` silently
   creates broken links instead of failing. Fix `rules` if needed.
5. If `.puavo-pkg-version` already has uncommitted changes (e.g. from an
   earlier build of the same update), revert it first with
   `git checkout <package>/.puavo-pkg-version`, so that the version number
   advances only one step past the last commit instead of once per rebuild.
6. Regenerate `.puavo-pkg-version` by running `make <package>.tar.gz` (or
   `./update_package_version <package>` directly). Never hand-edit that file
   — it stores a content hash of the package directory plus a version number
   and timestamp that only advance when the hash changes.
7. Stop there. Do not commit yet.
8. The person who asked for the update tests the built `.tar.gz` themselves,
   typically with `puavo-pkg install`, and will say explicitly when it works.
9. Only after that confirmation, create the git commit, matching the existing
   commit message style in this repo (e.g. "Update VS Code to version
   1.136.0.").
10. After the commit, remove the built `<package>.tar.gz` (or run `make clean`
   to clear all built tarballs at once) — they are gitignored build artifacts
   and shouldn't be left lying around in the working tree.

See `README.md` for the broader package build/update/testing commands.
