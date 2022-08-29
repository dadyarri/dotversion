# Dotversion

Dotversion is an application to increase version of .NET applications according to [SemVer](https://semver.org)

It automatically finds a `*.csproj` file in specified directory, reads current version from it, increases version as specified, and (if `-s` wasn't passed) writes it back.

## Help message

```
❯ dotversion --help
dotversion: Utility to increase versions of dotnet's projects according to SemVer (https://semver.org).

Usage:
   [options] dir [version_part]

Arguments:
  dir              Path to dotnet project
  [version_part]   Part of version (one of:
    - major,
    - minor,
    - patch,
    - alpha,
    - beta,
    - rc,
    - alpha-patch,
    - alpha-minor,
    - alpha-major,
    - beta-patch,
    - beta-minor,
    - beta-major,
    - rc-patch,
    - rc-minor,
    - rc-major
  ) (default: patch)

Options:
  -h, --help
  -s, --silent               Do not write new version to *.csproj file, only calculate and print.
  -v, --verbose              Show more verbose output

```
