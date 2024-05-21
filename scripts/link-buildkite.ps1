$ErrorActionPreference = 'Stop'  # Setting strict mode, similar to 'set -euo pipefail' in bash
. (Join-Path $PSScriptRoot "env.ps1")

Set-Location release
$CANARY_REVISION = 0
cmake .. -G Ninja -DCMAKE_BUILD_TYPE=Release `
  -DNO_CODEGEN=1 `
  -DNO_CONFIGURE_DEPENDS=1 `
  "-DCANARY=${CANARY_REVISION}" `
  -DBUN_LINK_ONLY=1 `
  "-DBUN_DEPS_OUT_DIR=$(Resolve-Path ../release/bun-deps)" `
  "-DBUN_CPP_ARCHIVE=$(Resolve-Path ../release/bun-cpp-objects.a)" `
  "-DBUN_ZIG_OBJ=$(Resolve-Path ../release/bun-zig.o)"
if ($LASTEXITCODE -ne 0) { throw "CMake configuration failed" }

ninja -v
if ($LASTEXITCODE -ne 0) { throw "Link failed!" }

$Dist = mkdir -Force "bun-windows-x64"
cp -r release\bun.exe "$Dist\bun.exe"
Compress-Archive -Force "$Dist" "${Dist}.zip"
$Dist = "$Dist-profile"
MkDir -Force "$Dist"
cp -r release\bun.exe "$Dist\bun.exe"
cp -r release\bun.pdb "$Dist\bun.pdb"
Compress-Archive -Force "$Dist" "$Dist.zip"

$env:BUN_GARBAGE_COLLECTOR_LEVEL = "1"
$env:BUN_FEATURE_FLAG_INTERNAL_FOR_TESTING = "1"
.\release\bun.exe --print "JSON.stringify(require('bun:internal-for-testing').crash_handler.getFeatureData())" > .\features.json
