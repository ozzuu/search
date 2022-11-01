# Package

version       = "1.1.0"
author        = "Ozzuu"
description   = "Open source, secure and privacy friendly meta search portal"
license       = "MIT"
srcDir        = "src"
bin           = @["search"]
binDir = "public/script"
backend = "js"


# Dependencies

requires "nim >= 1.6.4"
requires "karax"
requires "util"

task buildRelease, "Builds the release version":
  exec "nimble -d:danger --opt:speed build"
