# Economy and monetization status — September 2026

The polish build exposes earnable gems and cosmetic customization. It does not expose real-money purchases or ads. `MonetizationConfiguration.usesSimulatedAds` is false and `AppServices` selects `DisabledAdService`.

The old StoreKit catalog and simulated-ad adapter remain in source for development. They are not a working commercial integration. Do not describe this build as monetized, advertise a Remove Ads purchase, or turn placeholders on for release.

## Current dressing-room behavior

1. Open Dress up and select a color, hat, shoes, wings, or spots.
2. Inspect the assembled ladybug before confirming.
3. An owned item can be worn or removed. Buying an unowned item uses only earned gems.
4. With insufficient gems, Keep exploring returns to the menu.
5. Cost and cosmetic ownership share one versioned wallet snapshot. Transaction IDs are also stored there; repeated delivery on this installation is covered by unit tests.

The wallet is local to this installation. A local snapshot is not cloud recovery, cross-device synchronization, or proof of crash-safe purchase delivery in every circumstance.

## Recommended commercial next step

Evaluate a free opening chapter and one permanent full-adventure unlock after device playtests. The entitlement, stage access policy, localized purchase UI, and App Store products still need implementation and configuration. Keep existing player progress when introducing it.

Before enabling sales, test real StoreKit success, pending approval, cancellation, failed verification, interruption, restore, refunds/revocation, product unavailability, and ownership while offline. Decide reinstall and cross-device behavior explicitly. TestFlight and sandbox receipts are required evidence; simulator wallet tests alone are insufficient.

Keep ads, subscriptions, paid power, and paid random rewards outside the initial scope. Final audience and pricing remain product decisions.
