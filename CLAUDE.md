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

## Checking for available updates

When asked to "check updates", go through all packages and report which ones
have a newer upstream version. Produce a list only — do not edit, build or
commit anything; each actual update is a separate "update `<package>`"
request.

1. Read the pinned version from each package's `upstream_pack_url`, or from
   `rules` (`version=` / `urlbase=` variables) for packages without that file.
   `aversphere2`, `mandelbulber`, `mathpix`, `sparkvue` and
   `xeroxofficedriver` are empty stubs; skip them.
2. For GitHub-hosted packages, compare against
   `https://api.github.com/repos/<owner>/<repo>/releases/latest` (use curl if
   `gh` is not installed; the unauthenticated limit is 60 requests/hour).
   Bitwarden desktop and CLI share the `bitwarden/clients` repo, so filter
   its releases by the `desktop-v` / `cli-v` tag prefix. URL-encoded tags
   (e.g. `%40` for `@` in prusaslicer) are not real differences.
3. For other vendors, prefer machine-readable sources: "latest" download
   redirects (vscode, discord, zoom), apt repository `Packages` files
   (google-chrome, google-earth, signal — use `Packages.xz` —, sonobus,
   teamviewer, unityhub, spotify), version APIs (Firefox product-details,
   Slack `desktop.latestRelease`, HashiCorp checkpoint for vagrant, JetBrains
   releases API for pycharm), and directory listings or SourceForge RSS
   feeds (wine-mono, wine-gecko, kdenlive, eclipse, lazarus, sweethome3d).
4. Packages whose download URL has no version in it (dropbox, webex,
   teamviewer, airtame, …) can only be checked by downloading and comparing
   the sha384 checksum; list them as not checked unless asked. Opinsys
   internal builds, commit-pinned sources, drivers, firmware and fonts can be
   skipped.
5. Report in groups: newer version available (pinned vs. latest, flagging
   major jumps and very stale pins that may be intentional), likely outdated
   but unconfirmed, up to date, and could not check (with the reason).
