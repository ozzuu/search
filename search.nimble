# Package

version       = "0.1.0"
author        = "Thiago Navarro"
description   = "Ozzuu Search"
license       = "MIT"
srcDir        = "src"
bin           = @["search"]
binDir = "public/js"
backend = "js"


# Dependencies

requires "nim >= 1.6.4"
requires "karax"

task buildRelease, "Builds the release version":
  exec "nimble -d:release build"
