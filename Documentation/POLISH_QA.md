# Ladybug Run — polish delivery

Candidate: **1.0.0 (4)**, source `b302651b832c75c6209e0864ee0dd35ea36dc623`, developed on `polish/app-store-opening`.

## What changed

- Rebuilt the menu, paginated world map, field guide, dressing room, settings, and stage/failure results with a consistent visual style and safe-area layout.
- Added a replayable four-step flight school using the real player movement: lift, land, collect, and shelter.
- Added music, sound, haptics, reduced-effects, and relative-drag preferences. Menu controls provide accessibility labels and activation actions.
- Smoothed the ladybug's movement across refresh rates, added four walking frames and landing/collection reactions, and resolved competing blink/walk animation updates.
- Made all hat designs visible in game and in the assembled outfit previews.
- Added quiet scrolling habitat silhouettes and smooth skies. Biome atmosphere layers now leave with their biome, and silhouette opacity is applied once per layer for clean overlapping foliage.
- Added early-stage breathing room and advance warning for swooping threats. The 16-stage campaign and three boss mechanics remain the content foundation.
- Consolidated gem balance, cosmetic ownership, and delivered transaction IDs into one versioned local snapshot with legacy migration.
- Disabled the simulated ads and removed unfinished real-money merchandising from the visible shop. This candidate does not earn revenue yet.
- Fixed XcodeGen resource inclusion, launch-storyboard compatibility, iPhone device-family settings, display name, and opaque app-icon generation.
- Added Mac CI tests, screenshot artifacts, an unsigned Release IPA, dSYMs, source receipt, checksum, and a built-product resource gate. Codemagic retains the same sideload workflow with tests before archive.

## Verification

[Final CI run 35119514569](https://github.com/Yeastmans/Ladybuggame/actions/runs/35119514569) completed successfully on 16 September 2026.

- **6 unit tests and 2 UI tests passed, zero failures**, using Xcode 26.2 and an iPhone 16 Pro simulator running iOS 18.5.
- **30 actual simulator screenshots reviewed**: menu, map, settings in both landscape orientations, collection, dressing room, hat preview, tutorial, results, pause, all 16 biomes, and all three boss arenas. The final boss headings clear the stage HUD; the rotation capture is settled and upright.
- Release archive succeeded with the iOS 26.2 SDK and iOS 18 minimum deployment target.
- The downloaded **1.0.0 (4) IPA** passed the built-product gate locally. Its checksum matches the CI artifact and the source receipt identifies `b302651b832c75c6209e0864ee0dd35ea36dc623`.
- The generated icon is 1024 by 1024, RGB without an alpha channel. Debug screenshot launch flags are absent from the Release executable.
- All 64 checked source, test, script, resource, and build-configuration files match between the development directory and the delivery checkout, ignoring line-ending differences.

IPA SHA-256: `d44b1f21c717af8b0f9b61195e453fc4e77d3d943540e4dcb7227ab69dd24fda`.

The executable and build configuration were frozen at the source revision above. The later delivery commit only adds documentation. Local delivery folder: `Builds/LadybugRun-1.0.0-b4/`, including the IPA, checksum, receipt, dSYMs, icon, and reviewed screenshots.

The app-bundle gate checks the compiled asset catalog, primary icon metadata, compiled launch screen, privacy manifest, iPhone-only family, and SDK version. It correctly rejected the earlier incomplete IPA. Final verification is against the downloaded package, not just the project YAML.

## What the evidence does not establish

- Simulator captures show actual rendering, but do not establish control feel, silent-switch/headphone behavior, thermals, battery use, or long-session performance on a physical iPhone.
- Initial captures of all biomes and bosses do not prove every level or boss has been completed or balanced. Result screenshots use debug fixtures around the real overlays; they are not end-to-end completion evidence. Test the full campaign with new players.
- Local wallet tests do not establish reinstall recovery, cloud synchronization, or production StoreKit purchase correctness.
- Menu accessibility hooks are implemented; a human VoiceOver pass and broader accessibility testing remain necessary.
- The IPA is unsigned. It requires signing for device installation; no TestFlight upload, App Store submission, or monetization activation has occurred.

Use `TESTFLIGHT_SETUP.md` for the owner account tasks and first device test. Use `MONETIZATION_TESTING.md` for the current economy and proposed commercial next step.
