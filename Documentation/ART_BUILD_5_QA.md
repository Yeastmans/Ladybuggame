# Artwork pass — 1.0.0 (5)

Source: `5b84be9fd62350c5ce3b2dd9a7f927c2cda0bbfc`. This pass improves generated creature shading, the living ladybug's face, cloud silhouettes, habitat vegetation, mountain caps, mushrooms, and flat-ground texture. See `ART_DIRECTION.md` for the scope and visual rules. Physics, collision sizes, campaign structure, and Endless rules are unchanged.

## Verified evidence

- [GitHub run 35162837279](https://github.com/Yeastmans/Ladybuggame/actions/runs/35162837279) passed six unit tests and two UI tests, with zero failures, then produced a Release archive.
- Xcode 26.2; simulator: iPhone 16 Pro, iOS 18.5; archived SDK: iOS 26.2; minimum supported OS: iOS 18.
- Reviewed 31 actual simulator captures: the existing 30-screen navigation/habitat/boss suite plus a close-up gallery of real generated creature textures. The gallery is a debug review fixture, not a shipping game screen.
- Visual review confirmed smooth cloud silhouettes, distinct Meadow/Jungle/Swamp vegetation, textured terrain below the action, preserved menu/outfit previews, and legible gameplay HUDs in the captured scenes.
- The downloaded GitHub IPA passed the resource gate: compiled assets, app icon metadata, launch screen, privacy manifest, display name, and iPhone-only device family.
- Downloaded IPA checksum matches the CI checksum; its receipt matches the source revision above. Version/build is 1.0.0 (5). Debug launch fixtures and the art-review scene are absent from the Release executable.
- Generated app icon remains 1024 by 1024 RGB, with no alpha channel. All 64 checked application, test, script, resource, and project files match between development and delivery checkouts, ignoring line endings.

IPA SHA-256: `6f42252c22b6fef04fc09eca02cd008592d9d7f5b367af712b235bba00a11fe5`.

Local package: `Builds/LadybugRun-1.0.0-b5/`. The packaged IPA and checksum come from the GitHub run, not a re-export from Codemagic.

## Codemagic

The connected Ladybuggame project loaded the current repository configuration and started the same artwork branch in [Codemagic](https://codemagic.io/app/69c823503b330bce7de88af0/build/6aab279346519f5c57185cbf). This run was canceled after its simulator repeatedly failed to start Core Audio and stalled during testing. Build 6 adds an automated-test-only audio bypass and retries the pipeline; see `ART_BUILD_6_QA.md` for that outcome. The successful GitHub evidence above remains valid for build 5.

## Remaining device checks

Simulator screenshots do not establish iPhone control feel, motion readability, frame rate over long runs, battery use, or complete level/boss balance. Check the new art on your iPhone, including the darker worlds and transitions between biomes. Result overlays and boss/biome entry captures are debug fixtures, not evidence of full campaign completion.

The IPA is unsigned and needs signing before installation. Monetization and App Store submission remain separate work. Use `TESTFLIGHT_SETUP.md` for installation and account steps, and `ENDLESS_MODE.md` for the current survival-mode rules.
