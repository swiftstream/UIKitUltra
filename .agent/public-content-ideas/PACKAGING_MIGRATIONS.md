# Packaging and Migration Public Content Ideas

## CocoaPods support removal

Status: implemented
Good for: release notes | migration guide | README

### Why users should care

UIKitUltra no longer supports CocoaPods in the current release line. The legacy
`UIKit-Plus.podspec` has been removed and public installation guidance now
points to Swift Package Manager only. Users still depending on UIKitUltra through
CocoaPods need an explicit migration notice rather than discovering the change
from a missing Podspec.

### Required release-note message

The release that first ships this change must explicitly state all of the
following:

- CocoaPods installation is no longer supported by UIKitUltra;
- Swift Package Manager is the supported dependency-manager path;
- users of the old CocoaPods integration should migrate to SwiftPM;
- the rationale is the CocoaPods project's maintenance-mode direction and the
  announced transition of CocoaPods Trunk to permanent read-only for new
  Podspec publication.

Do not claim that all CocoaPods infrastructure had already shut down before
that is factually true. The user-facing wording may describe the ecosystem as
being wound down / publication through Trunk as being shut down, but should
distinguish that from existing CocoaPods builds ceasing to function.

### Evidence / provenance

- `README.md` no longer advertises CocoaPods installation.
- root `UIKit-Plus.podspec` removed in the same M1 packaging/layout correction.
- durable status owner: `.agent/PROJECT_MEMORY.md`.
- packaging/source owner: `.agent/SOURCE_MAP.md`.

### Publication caveat

This entry is implemented in the working tree but not yet shipped. Release-note
copy must be written against the actual release date/status of CocoaPods at that
time, not frozen to a premature claim that the whole service is already offline.
