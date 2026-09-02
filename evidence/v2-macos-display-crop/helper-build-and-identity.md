# Helper build and stable identity

## Date, machine state, and authority

- Date: 2026-09-02 PDT.
- Machine state: accepted arm64 Mac, macOS 26.4.1 build 25E253, with full Xcode
  selected at `/Applications/Xcode.app/Contents/Developer`.
- Central basis/tree:
  `7c15abaf55c0080b2f80971e845b4ee6f1bfcc46` /
  `730726784b57016714c0a44c8f0f8caf1c5b0141`.
- Source PR/head/tree:
  [PR #43](https://github.com/kasselvania/standalone-BitWig-push/pull/43) /
  `03fb8c8824714e4bbefd7224848ca9cdad069088` /
  `f1f68bc6f0ba6527bb146a7ee93fd4333ffaf796`.

## Toolchain

- Xcode 26.4.1 build 17E202.
- Apple Swift 6.3.1, target `arm64-apple-macosx26.0`.
- macOS SDK 26.4 under the selected full Xcode installation.
- `codesign`: `/usr/bin/codesign`. This macOS build does not implement
  `codesign --version`; that invocation returned its usage text and was not
  misreported as a version.

## Commands and tools

The retained inventory commands were `sw_vers`, `uname -a`, `uname -m`,
`xcode-select -p`, `xcodebuild -version`, `xcrun swift --version`,
`xcrun --sdk macosx --show-sdk-version`,
`xcrun --sdk macosx --show-sdk-path`, `which codesign`, and
`codesign --version`. Hostname text from `uname -a` was not retained.

## Exact build

From the exact source head, the normal build was:

```text
capture/macos/scripts/build-app.sh <external-scratch-directory>
```

The script performed a release SwiftPM build, assembled the retained app
wrapper, copied the exact `Info.plist` and executable, ad-hoc signed the app,
verified the signature, and read back the bundle identifier. Generated source
products stayed outside tracked source and were not committed.

The exact candidate was copied without modification to the stable local path
`$HOME/Applications/PushwigCaptureHelper.app` so LaunchServices and TCC saw a
stable application identity. File hashes proved the executable at the build
and stable paths was identical.

## App and signature identity

| Item | Result |
| --- | --- |
| Bundle identifier | `com.kasselvania.pushwig.capture-helper` |
| Executable type | Mach-O 64-bit executable arm64 |
| Executable size | 387,376 bytes |
| Executable SHA-256 | `9a81bb292cfa00588c4be0272abb11a2e223132feb8725aca6e2c6a808bf942a` |
| `Info.plist` SHA-256 | `f9bd4954b240300babcb79defb2df334818c17329c276b9c3b93a332f8ee17c0` |
| `_CodeSignature/CodeResources` SHA-256 | `6686de10a28a2fe11b36cbb86dcbacc827cfc4ea116b4dabf1845e5aee629e9b` |
| Sorted app-tree manifest SHA-256 | `2bdac424842bc6af5b91eb0d18ea5a23c3626c7b16078c41f3b667cbee5c8d13` |
| CodeDirectory CDHash | `816ea0f9c24184ac44df1e1e0642a1d3a59accf6` |
| Full candidate CodeDirectory hash | `816ea0f9c24184ac44df1e1e0642a1d3a59accf65d809ee754a099d9980b2a52` |
| Signature | valid ad-hoc development signature; no Team ID claim |

`codesign --verify --deep --strict --verbose=2`, `codesign -dv --verbose=4`,
`plutil -extract CFBundleIdentifier`, `file`, a sorted relative-path/size/hash
manifest, and `shasum -a 256` supplied these readbacks.

## Deterministic verification

`xcrun swift test` against the exact amended source head passed 15 tests with
zero failures. They cover explicit configuration, point-consistent display
matching/drift, maximal fractional centered-cover geometry (including the
`559x160` non-clean-GCD case), wider/taller crops, invalid/nonfinite geometry,
padding-excluding opaque BGRA conversion, protocol header network order,
sequence progression/exhaustion, one-CLEAR authority transitions,
running/frontmost source validity, and a stalled-reader bounded-write case.
Strict recursive `swift-format` lint also passed.

A temporary executable-level negative harness exercised 21 invalid/runtime
cases. Harness source SHA-256 was
`a63874d353ad1629789fddd56688d92453cd1030a8f38e6fef2c12a69e0f19b8`.
All cases exited nonzero with bounded actionable output and zero capture,
connection, or crash. The harness and binary were removed and are not
committed.

The repair reran the same 21-case shape against the exact amended app. The
temporary matrix script SHA-256 was
`caf8f750d38e0dc71dae9fb96d709fd728bcefb92094ada8f86cc22d8ff1c257`:
20 executable cases passed with the expected nonzero exits, and the exact-ID
runtime-unavailability case passed through the deterministic
`validateCurrent` test. The separate repeated stalled-reader harness source and
binary SHA-256 values were
`e17ed88e8b19ead9202a76de0fcc4bd943e5bb4777893a2148174e317a980383`
and
`5c9831c3ef440379726a34e8104755c537f6ed538c16e92cb1ab7e3fcab5468b`.
All temporary sources and binaries were removed after retaining results.

## Stable Screen Recording attribution

Launching a temporary build path directly was deliberately rejected as stable
TCC proof: System Settings did not list the helper, and narrow public unified
logging showed the temporary path rather than durable bundle attribution.

The original V2 candidate binary (SHA-256
`7dc775f8eaa6ef50d85c24394ca22e492ceba9cd07738b97a893f0a3604564cc`)
was then launched through the stable app bundle
with `/usr/bin/open -n -W --stdout ... --stderr ... <app> --args ...`.
Before permission, it reported
`PERMISSION preflight=denied request=denied attribution=helper-app`, published
no frame, and exited boundedly. Narrow public TCC logging identified
`com.kasselvania.pushwig.capture-helper` at the `$HOME/Applications` path.
After the maintainer enabled that exact app manually in Screen Recording, the
same executable hash relaunched with preflight granted and captured
successfully. No private TCC API, database edit, or `tccutil reset` was used.

The amended exact-head executable replaced it at that same stable app path,
retained the same bundle identifier and app shape, reported
`PERMISSION preflight=granted attribution=helper-app`, and completed the focused
live capture. The repair did not repeat the already accepted denial/regrant
matrix, so denial is not claimed for the amended executable hash.

## Exact result

The exact amended source passed its release build, app assembly/signature
readback, 15-test Swift suite, and 21-case executable negative matrix. Public
TCC evidence binds the original denial/regrant proof to one stable bundle ID,
app path, executable hash, and ad-hoc signature identity. The amended executable
then reused that stable identity and independently proved granted capture.

## What this proves

- The proposed source builds reproducibly enough to identify one exact normal
  application bundle and executable, with stable bundle/signature/TCC identity.
- The accepted original denial and regrant halves used the same exact binary
  and public APIs; the amended exact binary was separately read back as granted
  and used successfully.

## What this does not prove

- Ad-hoc signing is a development identity, not Developer ID notarization, an
  installer, or App Store distribution.
- The app-tree hash identifies this build; it does not claim bit-for-bit builds
  across arbitrary Swift/Xcode versions.
