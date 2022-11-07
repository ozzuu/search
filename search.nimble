# Package

version       = "2.0.0"
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

from std/os import `/`
from std/strformat import fmt

let outFile = binDir / bin[0] & ".js"

task buildRelease, "Builds the release version":
  exec "nimble -d:danger --opt:speed build"
  exec fmt"uglifyjs -o {outFile} {outFile}"
