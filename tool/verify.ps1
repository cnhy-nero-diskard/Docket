$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Push-Location $root
try {
  New-Item -ItemType Directory -Force -Path 'docs/evidence' | Out-Null
  function Invoke-DocketCheck($name, [scriptblock]$command) {
    $destination = Join-Path $root "docs/evidence/$name.txt"
    $ErrorActionPreference = 'Continue'
    & $command 2>&1 | ForEach-Object {
      $_.ToString().Replace($env:USERPROFILE, '<user-profile>').Replace($root, '<worktree>') `
        -replace 'https://[^/\s]+@github.com', 'https://github.com' `
        -replace '-Pdart-defines=[^\s]+', '-Pdart-defines=<toolchain-defines-redacted>'
    } | Tee-Object -FilePath $destination
    $ErrorActionPreference = 'Stop'
    if ($LASTEXITCODE -ne 0) { throw "$name failed (exit $LASTEXITCODE)" }
  }
  Invoke-DocketCheck 'format' { dart format --output=none --set-exit-if-changed lib test integration_test }
  Invoke-DocketCheck 'analyze' { flutter analyze --no-pub }
  Invoke-DocketCheck 'common-tests' { flutter test --no-pub --reporter expanded }
  Invoke-DocketCheck 'openspec' { openspec.cmd validate validate-cross-platform-foundations --strict }
} finally { Pop-Location }
