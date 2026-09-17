# Artwork pass â€” 1.0.0 (5)

Source: `ba8411b757f1186b29275c115b28d7b4f734f391`. This pass improves generated creature shading, the living ladybug's face, cloud silhouettes, habitat vegetation, mountain caps, mushrooms, and flat-ground texture. See `ART_DIRECTION.md` for the scope and visual rules. Physics, collision sizes, campaign structure, and Endless rules are unchanged.

## Verified evidence

- [GitHub run 35163770849](https://github.com/Yeastmans/Ladybuggame/actions/runs/35163770849) passed six unit tests and two UI tests, with zero failures, then produced a Release archive.
- Xcode 26.2; simulator: iPhone 16 Pro, iOS 18.5; archived SDK: iOS 26.2; minimum supported OS: iOS 18.
- Reviewed 31 actual simulator captures: the existing 30-screen navigation/habitat/boss suite plus a close-up gallery of real generated creature textures. The gallery is a debug review fixture, not a shipping game screen.
- Visual review confirmed smooth cloud silhouettes, distinct Meadow/Jungle/Swamp vegetation, textured terrain below the action, preserved menu/outfit previews, and legible gameplay HUDs in the captured scenes.
- The downloaded GitHub IPA passed the resource gate: compiled assets, app icon metadata, launch screen, privacy manifest, display name, and iPhone-only device family.
- Downloaded IPA checksum matches the CI checksum; its receipt matches the source revision above. Version/build is 1.0.0 (6). Debug launch fixtures and the art-review scene are absent from the Release executable.
- Generated app icon remains 1024 by 1024 RGB, with no alpha channel. All 64 checked application, test, script, resource, and project files match between development and delivery checkouts, ignoring line endings.

IPA SHA-256: `e40e04cfbcf1117fd9fcc8a405b5156f08b431ebc6f1a5deb7284fbf13c6ae6c`.

Local package: `Builds/LadybugRun-1.0.0-b6/`. The packaged IPA and checksum come from the GitHub run, not a re-export from Codemagic.

## Codemagic

The connected Ladybuggame project completed [Codemagic build 6aab2a835873fbdb1cda5b15](https://codemagic.io/app/69c823503b330bce7de88af0/build/6aab2a835873fbdb1cda5b15) successfully: simulator tests, Release archive, unsigned IPA packaging, and artifact publishing. Its built-product log reports version 1.0.0 (6), iOS 26.2 SDK, and a passing resource gate.

The preceding build 5 Codemagic attempt stalled because the host simulator's Core Audio service could not start; it was canceled. Build 6 bypasses audio initialization only in automated DEBUG simulator tests. The iPhone Release game retains audio. These silent visual/logic tests do not verify sound playback. Build 5's artwork had already passed the earlier GitHub run; the final 31 build 6 captures were reviewed again.

The final delivery commit adds documentation only; executable code is the source revision above.

## Remaining device checks

Simulator screenshots do not establish iPhone control feel, motion readability, frame rate over long runs, battery use, or complete level/boss balance. Check the new art on your iPhone, including the darker worlds and transitions between biomes. Result overlays and boss/biome entry captures are debug fixtures, not evidence of full campaign completion.

The IPA is unsigned and needs signing before installation. Monetization and App Store submission remain separate work. Use `TESTFLIGHT_SETUP.md` for installation and account steps, and `ENDLESS_MODE.md` for the current survival-mode rules.
