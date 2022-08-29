# Package

version       = "1.0.0"
author        = "Daniil"
description   = "Application to increase version of dotnet package according to semver"
license       = "MIT"
srcDir        = "src"
bin           = @["dotversion"]


# Dependencies

requires "nim >= 1.6.6"
requires "argparse"
requires "semver"
