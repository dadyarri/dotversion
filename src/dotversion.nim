import os
import std/xmlparser
import std/xmltree
import std/strutils

import argparse
import semver

proc is_valid_version_transition(old_build: string, new_build: string): bool =
  return (
    (old_build == "alpha" and new_build == "beta") or
    (old_build == "alpha" and new_build == "rc") or
    (old_build == "beta" and new_build == "rc") or
    (old_build == new_build)
  )

proc increase_patch(version: var Version): void =
  version.build = ""
  version.patch += 1

proc increase_minor(version: var Version): void =
  version.build = ""
  version.patch = 0
  version.minor += 1

proc increase_major(version: var Version): void =
  version.build = ""
  version.patch = 0
  version.minor = 0
  version.major += 1

proc increase_build(version: Version, build_type: string): string =
  if version.build == "":
    return build_type & ".0"
  else:

    var build = version.build.split(".")
    if is_valid_version_transition(build[0], build_type):

      if build[0] != build_type:
        build[0] = build_type
        build[1] = "0"
      else:
        build[1] = $(parseInt(build[1]) + 1)

      return build.join(".")
    else:
      stderr.writeLine "Can't decrease version of application: " & build[0] & " -> " & build_type
      quit(1)

var p = newParser:
  help("{prog}: Utility to increase versions of dotnet's projects according to SemVer (https://semver.org).")
  arg("dir", help="Path to dotnet project")
  arg("version_part", help="""Part of version (one of:
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
  )""", default=some("patch"))
  flag("-s", "--silent", help="Do not write new version to *.csproj file, only calculate and print.")
  flag("-v", "--verbose", help="Show more verbose output")

try:
    let opts = p.parse(commandLineParams())
    let absPath = absolutePath(opts.dir)
    let projectFile = absPath & "/" & splitPath(absPath).tail & ".csproj"

    if opts.verbose:
      echo "Searching for project file: " & projectFile & "..."

    if fileExists(projectFile):
      var project = loadXml(projectFile)
      var version_node = project.child("PropertyGroup").child("Version")
      echo "Current version: " & version_node.innerText()

      var version = parseVersion(version_node.innerText())

      case opts.version_part:
        of "patch":
          increase_patch(version)
        of "minor":
          increase_minor(version)
        of "major":
          increase_major(version)
        of "alpha-patch":
          increase_patch(version)
          version.build = increase_build(version, "alpha")
        of "alpha-minor":
          increase_minor(version)
          version.build = increase_build(version, "alpha")
        of "alpha-major":
          increase_major(version)
          version.build = increase_build(version, "alpha")
        of "beta-patch":
          increase_patch(version)
          version.build = increase_build(version, "beta")
        of "beta-minor":
          increase_minor(version)
          version.build = increase_build(version, "beta")
        of "beta-major":
          increase_major(version)
          version.build = increase_build(version, "beta")
        of "rc-patch":
          increase_patch(version)
          version.build = increase_build(version, "rc")
        of "rc-minor":
          increase_minor(version)
          version.build = increase_build(version, "rc")
        of "rc-major":
          increase_major(version)
          version.build = increase_build(version, "rc")
        of "alpha", "beta", "rc":
          version.build = increase_build(version, opts.version_part)
        else:
          stderr.writeLine "Wrong part's name: " & opts.version_part
          quit(1)

      echo "New version: " & $version

      if not opts.silent:

        var version_text = newText($version)
        version_node.delete(0)
        version_node.add(version_text)

        let file = open(projectFile, fmWrite)
        file.write(project)
        file.close()

    else:
      stderr.writeLine "Seems like " & absPath & " is not a .NET project..."
      quit(1)

except ShortCircuit as e:
    if e.flag == "argparse_help":
        echo p.help
        quit(0)
except UsageError:
    stderr.writeLine getCurrentExceptionMsg()
    quit(1)

