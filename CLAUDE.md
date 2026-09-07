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
4. Regenerate `.puavo-pkg-version` by running `make <package>.tar.gz` (or
   `./update_package_version <package>` directly). Never hand-edit that file
   — it stores a content hash of the package directory plus a version number
   and timestamp that only advance when the hash changes.
5. Stop there. Do not commit yet.
6. The person who asked for the update tests the built `.tar.gz` themselves,
   typically with `puavo-pkg install`, and will say explicitly when it works.
7. Only after that confirmation, create the git commit, matching the existing
   commit message style in this repo (e.g. "Update VS Code to version
   1.136.0.").

See `README.md` for the broader package build/update/testing commands.
