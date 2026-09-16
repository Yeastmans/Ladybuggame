# From the polish build to TestFlight

The current GitHub and Codemagic workflows build an **unsigned** iPhone IPA for sideload testing. That package is not an App Store upload and still requires signing before installation. The debug-only screenshot fixtures are excluded from the Release archive.

## Try the IPA on your iPhone now

The project's existing sideload route is [Sideloadly](https://sideloadly.io/). On Windows, follow its official iTunes/iCloud prerequisites, connect your iPhone, load `LadybugRun-unsigned.ipa`, select the phone, and complete signing in Sideloadly. Enter Apple account details in that app. Sideloadly supports free Apple IDs; free-account installs require periodic refresh. Keep the bundle identifier consistent when updating an existing test installation so you can check save migration.

This is a device-testing route. TestFlight and App Store distribution use the membership and distribution-signing setup below.

## Account setup — owner tasks

1. Enroll in the Apple Developer Program. Choose individual or organization seller identity deliberately. Apple lists an annual US$99 fee, with local pricing where available. See [Apple enrollment](https://developer.apple.com/programs/enroll/).
2. Confirm the app name is available and register the final bundle ID. The current project uses `com.ladybuggame.LadybugGame`; do not change it casually after distribution.
3. Create the iOS app record in App Store Connect with that bundle ID. Complete the required agreements, banking, and tax information before selling anything.
4. Provide your public support contact, seller details, and final audience choice. These must be your real declarations.

## Codemagic signing setup

Create a dedicated App Store Connect API key and add it through Codemagic's Apple Developer Portal integration. Store the private key in the service's secure configuration, never in Git. Add an Apple Distribution certificate and matching App Store provisioning profile to Code signing identities.

For the signed workflow, set `environment.ios_signing.distribution_type: app_store` with the final bundle ID, apply profiles using `xcode-project use-profiles`, and replace the unsigned packaging step with signed archive/export. Keep the existing simulator tests before archiving. See [Codemagic signing](https://docs.codemagic.io/yaml-code-signing/signing-ios/).

Configure `publishing.app_store_connect` with the saved integration, upload the signed IPA, and initially distribute through TestFlight. Keep automatic App Store submission disabled. Assign increasing build numbers for uploads and retain dSYMs. See [Codemagic publishing](https://docs.codemagic.io/yaml-publishing/app-store-connect/).

This signed workflow has not been executed or authenticated yet. Finish the account configuration before treating it as a working release pipeline.

## First iPhone playtest — about 20 minutes

- Begin with a new tutorial. Try either side of the screen; lift, release, collect, hide. Replay it from Settings.
- Play Meadow without coaching. Note the first moment where a danger or instruction is unclear.
- Compare Follow finger and Drag controls. Check whether your finger obscures the action.
- Pause, lock the phone, return, and resume. Switch apps during a run; the run should return paused.
- Toggle sound, music, haptics, and effects. Relaunch and check the choices persist. Test the silent switch and headphones.
- Earn and spend gems, equip a hat, relaunch, and check ownership and balance.
- Rotate between both landscape directions and check HUD/buttons near the camera cutout and home indicator.

Record phone model, iOS version, build number, stage, and reproduction steps for problems. Capture a short clip when control feel or a collision is involved.

## Before App Store submission

Play all 16 stages and every boss to completion on devices; short simulator captures only prove initial rendering. Check performance over repeated runs and verify all power-ups and checkpoint/save paths. Finalize and sandbox-test the chosen purchase model, then match privacy declarations to the actual shipping services. Prepare real gameplay screenshots, icon, support/privacy URLs, age rating, compliance answers, and review notes. Submit the tested signed candidate and select manual release.
