# Monetization Test Build

This build enables the complete monetization flow without connecting to an ad network.

## Simulated ads

- Rewarded ads display a blank black screen for 5 seconds.
- Interstitial ads display a blank black screen for 3 seconds.
- A reward is granted only when the full simulated ad completes.
- Closing or interrupting a future production ad must report failure and grant nothing.
- Interstitials still obey the normal cap: after three eligible runs, at least four minutes apart, and never during gameplay.
- The Remove Ads entitlement disables interstitials but not optional rewarded ads.

The temporary switch is `MonetizationConfiguration.usesSimulatedAds` in `SimulatedAdService.swift`. It must be replaced with a production provider and set to `false` before App Store submission.

## Test flows

1. Lose all lives and choose **Test Ad • Revive**. After 5 seconds the run resumes with one life and brief invincibility. This is limited to once per run.
2. Complete a stage with a gem reward and choose **Test Ad • Double**. After 5 seconds the same reward is granted once more.
3. Open **Shop → Get Gems** and choose the daily test-ad bonus. After 5 seconds, 5 gems are granted. It is available once per calendar day.
4. Complete three runs that each last at least 60 seconds. The next result-screen exit displays a 3-second blank interstitial.
5. StoreKit buttons use real StoreKit 2 products. They remain unavailable until matching products are configured in App Store Connect (or an Xcode StoreKit test configuration).

## Before release

- Replace `SimulatedAdService` with the selected ad network adapter.
- Add consent/privacy choices and production ad-unit IDs.
- Configure all StoreKit product IDs and prices in App Store Connect.
- Test purchase success, pending, cancellation, refunds, revocation, restore, ad interruption, and offline/no-fill behavior.
- Confirm the privacy manifest and App Store privacy answers match the final SDKs.
