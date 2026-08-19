# Ladybug Run — Product Strategy and Release Roadmap

## Product goal

Turn the current SpriteKit prototype into a polished, replayable, commercially viable iPhone game. Revenue is an outcome of retention, player trust, discoverability, and disciplined testing; ads by themselves do not guarantee profit.

The recommended launch positioning is a family-friendly game for a general audience, not an App Store Kids Category title. If the game is intentionally marketed primarily to children under 13, the privacy, analytics, advertising, store, and parental-gate design must be changed before third-party SDKs are added.

## What already works

- A distinctive one-touch run/fly control scheme.
- Fifteen themed biomes with bespoke creatures and hazards.
- Three bosses with different solutions.
- Cosmetic shop, earnable gems, Bugopedia, difficulty modes, and checkpoints.
- Programmatic art and audio, which keeps the binary compact and avoids asset licensing risk.

## Current commercial blockers

- The core game is one long score run rather than a clear mobile progression journey.
- New players receive no guided tutorial, goals, or early-session reward cadence.
- The game-over screen has no replay funnel, run summary, revive, or reward choice.
- No daily missions, achievements, streaks, events, or return incentives.
- No analytics, crash reporting, remote tuning, or A/B-test capability.
- Purchases, advertising, consent, privacy choices, and restore-purchases flows do not exist.
- Player state is split across raw `UserDefaults` keys and has no schema version, migration, or cloud recovery.
- `GameScene.swift` is over 4,700 lines, making balancing and regression control increasingly risky.
- There are no automated tests or signed TestFlight/App Store pipeline.
- Accessibility, localization, safe-area support, haptics, settings, and device QA need a production pass.

## Recommended game structure

### 1. Adventure mode

Turn each biome into a short, named stage with a visible objective and completion reward. A stage should have a predictable endpoint and usually last 90–180 seconds. Preserve the current continuous runner as Endless Mode, unlocked after the first boss.

Each stage gets one of a small set of readable goals:

- Reach the finish.
- Eat a target number of snacks.
- Collect a rare creature.
- Avoid taking more than a set amount of damage.
- Survive a hazard sequence.
- Defeat a boss using its unique mechanic.

This gives players a reason to replay a specific biome and gives the game clean places to award currency, show optional ads, and introduce new mechanics.

### 2. Meta progression

- Player level based on earned XP, never purchased directly.
- Three-star stage mastery with skill-based objectives.
- Bugopedia collection rewards at meaningful completion thresholds.
- Cosmetic sets with visible rarity and themed collections.
- Achievements and Game Center leaderboards.
- Daily missions (three per day) and one weekly challenge.
- Daily reward calendar with a forgiving streak, not a punitive reset.

### 3. Economy

Launch with one spendable currency: Gems. Gems can be earned through play and optionally purchased. Purchased currency must never expire.

Sources:

- Stage completion and mastery.
- Boss victories.
- Daily/weekly missions.
- Rare in-run drops.
- Optional rewarded-ad bonuses.
- StoreKit gem packs.

Sinks:

- Cosmetics only at launch.
- Cosmetic set bundles.
- Optional mission reroll with a strict daily cap.

Do not sell direct combat power for launch. It makes balancing harder and weakens player trust.

## Monetization model

### Rewarded ads

- One revive per run, offered only after the first meaningful run.
- Double the normal run/stage reward after completion.
- Optional daily bonus chest.

The reward must be granted only after the ad provider confirms completion. Declining an ad must never block normal progression.

### Interstitial ads

- Only at a natural break after a run or completed stage.
- Never during active play or immediately after app launch.
- No interstitial after a very short failed run.
- Frequency cap: at most one after every three eligible runs and at least four minutes apart.
- Disabled permanently for the Remove Ads entitlement.

### In-app purchases

Proposed launch catalog (final local prices are selected in App Store Connect):

- Remove Ads — non-consumable.
- Starter Pack — one-time non-consumable containing a cosmetic set and gems.
- Small, medium, and large gem packs — consumable.
- One direct-purchase seasonal cosmetic set — non-consumable.

Avoid subscriptions until the game has recurring live content that clearly justifies an ongoing payment. Avoid paid randomized rewards; if any paid randomized mechanism is ever introduced, odds must be disclosed before purchase.

## Analytics event plan

Measure behavior, not personal identity:

- App/session opened and closed.
- Tutorial step started/completed/skipped.
- Run started/ended, duration, score, biome, difficulty, and death cause.
- Stage started/completed/failed and objective progress.
- Biome and boss reached/defeated.
- Economy source/sink with item and amount.
- Shop viewed, item previewed, purchase started/completed/failed/restored.
- Ad opportunity, loaded, shown, completed, skipped, and failed by placement.
- Daily mission and reward events.

Launch gates should be based on measured quality goals, including crash-free sessions, tutorial completion, early-stage completion, first-day return, and rewarded-ad opt-in. Revenue tuning comes after retention is healthy.

## Delivery phases

### Phase 0 — Stabilize and instrument

- Split major responsibilities out of `GameScene`.
- Introduce versioned player-profile persistence and migration.
- Add analytics interfaces, deterministic economy policy, automated tests, and a debug menu.
- Add settings for music, sound, haptics, and control offset.
- Establish a signed TestFlight pipeline and build-number automation.

### Phase 1 — Mobile game shell

- First-run tutorial.
- Adventure map and stage model.
- Run/stage summary with Retry and Continue.
- Daily missions, player XP, mastery stars, achievements, and reward presentation.
- Improved menu, shop, pause, onboarding, and loading transitions.

### Phase 2 — Monetization and privacy

- StoreKit 2 catalog, transaction verification, restore purchases, and entitlement sync.
- Consent flow and privacy choices.
- Rewarded and interstitial ads behind a provider-neutral service.
- Remove Ads entitlement and frequency caps.
- App privacy manifest, privacy policy, and accurate App Store privacy disclosures.

### Phase 3 — Quality and content

- Animation, effects, haptics, sound mix, and readability pass across every biome.
- Performance budget and texture caching.
- Accessibility and safe-area pass.
- English copy polish, then localization-ready strings.
- Device matrix QA and TestFlight beta feedback loop.

### Phase 4 — Launch and live operations

- App Store listing, screenshots, preview video, support/privacy pages, and review notes.
- Soft launch to measure retention, difficulty, ad frequency, and economy balance.
- Fix launch blockers before broader release.
- Monthly content cadence only after the base game metrics are stable.

## Definition of launch-ready

- All primary flows work offline and recover cleanly after interruption.
- Purchases are verified and restorable; consumables cannot be double-granted.
- Ads respect consent, age/audience policy, frequency caps, and Remove Ads.
- No forced ad interrupts active play.
- Progress migration and restore are tested.
- No placeholder email addresses, product IDs, icons, policy links, or ad IDs remain.
- Signed release build reaches TestFlight from Codemagic.
- Privacy policy and App Store privacy answers match every included SDK.
- App Store screenshots and metadata represent the actual game.
- Crash-free and gameplay targets are met in a real-device beta cohort.
