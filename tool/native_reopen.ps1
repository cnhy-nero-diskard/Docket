$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$exe = Join-Path $root 'build/windows/x64/runner/Release/docket.exe'
$ready = Join-Path $root 'docs/evidence/native-commit.json'
$reopened = Join-Path $root 'docs/evidence/native-reopen.json'
foreach ($file in @($ready, $reopened)) {
  if (Test-Path -LiteralPath $file) { Remove-Item -LiteralPath $file }
}
$process = Start-Process -FilePath $exe -ArgumentList @('write', $ready) -WorkingDirectory $root -WindowStyle Hidden -PassThru
try {
  $deadline = (Get-Date).AddSeconds(30)
  while (!(Test-Path -LiteralPath $ready)) {
    if ($process.HasExited -or (Get-Date) -gt $deadline) { throw 'Native commit probe did not become ready' }
    Start-Sleep -Milliseconds 100
  }
  Stop-Process -Id $process.Id -Force
  $process.WaitForExit()
  $reader = Start-Process -FilePath $exe -ArgumentList @('reopen', $reopened) -WorkingDirectory $root -WindowStyle Hidden -PassThru
  if (!$reader.WaitForExit(30000)) { Stop-Process -Id $reader.Id -Force; throw 'Reopen timed out' }
  $result = Get-Content -Raw -LiteralPath $reopened | ConvertFrom-Json
  if ($result.outcome -ne 'PASS') { throw 'Committed record did not survive forced termination' }
  Get-Content -LiteralPath $ready,$reopened
} finally {
  if (!$process.HasExited) { Stop-Process -Id $process.Id -Force }
}
