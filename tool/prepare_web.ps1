$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Push-Location $root
try {
  $release = 'https://github.com/simolus3/drift/releases/download/drift-2.35.1'
  $expected = @{
    'sqlite3.wasm' = 'FBCD2E8214F9231EA961E1B7706A22DD1194CFBFE6F26F13841B5AA7A0BE1A1F'
    'drift_worker.js' = 'FE5F13BE0526F78293796AEFB9A29D3823A2DBDBF1BCCD3F0FAEB90EAAAFD72A'
  }
  foreach ($asset in @('sqlite3.wasm', 'drift_worker.js')) {
    Invoke-WebRequest -Uri "$release/$asset" -OutFile (Join-Path $root "web/$asset")
    if ((Get-FileHash -Algorithm SHA256 "web/$asset").Hash -ne $expected[$asset]) { throw "Unexpected $asset hash" }
  }
  Get-FileHash -Algorithm SHA256 web/sqlite3.wasm,web/drift_worker.js |
    Select-Object @{Name='Asset';Expression={Split-Path -Leaf $_.Path}},Hash
} finally { Pop-Location }
