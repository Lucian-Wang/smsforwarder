$ErrorActionPreference = 'Stop'
function Assert-Success { if ($LASTEXITCODE -ne 0) { throw "Command failed: $LASTEXITCODE" } }
foreach ($name in @('KEYSTORE_BASE64', 'KEYSTORE_PASSWORD', 'KEY_ALIAS', 'KEY_PASSWORD')) {
 if ([string]::IsNullOrWhiteSpace([Environment]::GetEnvironmentVariable($name))) { throw "Missing Actions secret: $name" }
}
$env:KEYSTORE_FILE = Join-Path $env:RUNNER_TEMP 'lucian-release.jks'
[IO.File]::WriteAllBytes($env:KEYSTORE_FILE, [Convert]::FromBase64String($env:KEYSTORE_BASE64))
$env:VERSION_NAME = '2.9.8'
if ($env:GITHUB_REF -like 'refs/tags/v*') { $env:VERSION_NAME = $env:GITHUB_REF.Substring(11) }
if ($env:INPUT_VERSION_NAME) { $env:VERSION_NAME = $env:INPUT_VERSION_NAME }
if ($env:VERSION_NAME -notmatch '^[0-9][0-9A-Za-z.+-]*$') { throw 'Invalid version name' }
$code = 1000 + [int]$env:GITHUB_RUN_NUMBER
if ($env:INPUT_VERSION_CODE) { $code = [int]$env:INPUT_VERSION_CODE }
if ($code -lt 1 -or $code -gt 2100000000) { throw 'Invalid version code' }
$env:VERSION_CODE = "$code"
& gradle --no-daemon clean assembleRelease "-PVERSION_NAME=$env:VERSION_NAME" "-PVERSION_CODE=$env:VERSION_CODE"
Assert-Success
$apks = @(Get-ChildItem 'app/build/outputs/apk/release' -Filter *.apk)
if ($apks.Count -ne 1) { throw 'Expected exactly one release APK' }
$apk = $apks[0].FullName
$bt = Join-Path $env:ANDROID_HOME 'build-tools/35.0.0'
New-Item -ItemType Directory -Path dist -Force | Out-Null
$output = 'dist/smsforwarder-release.apk'
& java -jar "$bt/lib/apksigner.jar" sign --ks $env:KEYSTORE_FILE --ks-key-alias $env:KEY_ALIAS --ks-pass env:KEYSTORE_PASSWORD --key-pass env:KEY_PASSWORD --out $output $apk
Assert-Success
$verification = & java -jar "$bt/lib/apksigner.jar" verify --verbose --print-certs $output
Assert-Success
$verification | Write-Output
$expected = 'eb60a97d6689c00fb23207e650be4f19e849e5207765c05fc969f3d485df8977'
if (($verification -join "`n") -notmatch "Signer #1 certificate SHA-256 digest: $expected") { throw 'Unexpected signing certificate' }
$aapt = Join-Path $bt 'aapt'
$badging = & $aapt dump badging $output
Assert-Success
if (($badging -join "`n") -notmatch "package: name='wang.lucian.smsforwarder'") { throw 'Wrong application ID' }
if (($badging -join "`n") -match 'application-debuggable') { throw 'Release APK is debuggable' }
(Get-FileHash $output -Algorithm SHA256).Hash.ToLower() + '  smsforwarder-release.apk' | Set-Content 'dist/SHA256SUMS.txt'
Write-Output "Verified release: wang.lucian.smsforwarder $env:VERSION_NAME ($env:VERSION_CODE)"
