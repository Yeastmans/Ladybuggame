# App Store Release Checklist

## Accounts and business setup

- [ ] Active Apple Developer Program membership.
- [ ] App record created in App Store Connect.
- [ ] Final app name, seller name, bundle identifier, SKU, and primary category selected.
- [ ] Paid Applications Agreement, tax forms, and banking completed.
- [ ] Support URL and public privacy-policy URL available.
- [ ] App Store Connect API key created for Codemagic with appropriate access.
- [ ] Apple Distribution certificate and App Store provisioning profile available to Codemagic.
- [ ] AdMob account/app created if AdMob is selected.
- [ ] Intended audience confirmed: general audience or child-directed.

## App and privacy

- [ ] Final bundle identifier replaces the prototype identifier if necessary.
- [ ] Marketing and build versions increment automatically.
- [ ] `PrivacyInfo.xcprivacy` accurately lists app API reasons and data collection.
- [ ] Third-party SDK privacy manifests/signatures verified in the release archive.
- [ ] App Store privacy answers include all ad, consent, analytics, and crash SDK behavior.
- [ ] Consent/privacy-options UI is reachable from Settings.
- [ ] ATT prompt is used only if the final configuration performs cross-app/site tracking.
- [ ] `NSUserTrackingUsageDescription` is present only if ATT is used.
- [ ] Ads include an in-app path for reporting inappropriate ads.
- [ ] Remove Ads entitlement is restored across devices.
- [ ] Purchased virtual currency never expires.

## Monetization QA

- [ ] StoreKit products configured in App Store Connect and localization complete.
- [ ] StoreKit configuration file covers local tests.
- [ ] Purchase success, pending, cancellation, failure, refund, revoke, and restore tested.
- [ ] Consumable transaction IDs cannot be granted twice.
- [ ] Rewarded ads grant only after completion callback.
- [ ] No-fill and offline ad paths fail gracefully.
- [ ] Frequency caps persist across sessions.
- [ ] No production build contains test ad IDs; no debug build requests production ads.
- [ ] Interstitials never interrupt active play.

## Game quality

- [ ] Tutorial can be completed and replayed.
- [ ] Every stage, biome transition, checkpoint, boss, and power-up tested on device.
- [ ] Easy/Normal/Hard balance tested with new and experienced players.
- [ ] Safe areas, Dynamic Island/notches, and supported iPhone aspect ratios tested.
- [ ] Background/foreground, audio interruption, phone call, lock, and low-memory behavior tested.
- [ ] Music, effects, haptics, and control settings persist.
- [ ] VoiceOver labels or equivalent accessible navigation supplied for menu/store controls.
- [ ] Color is not the only friend/enemy signal.
- [ ] No clipped text at supported display sizes.
- [ ] Frame pacing and memory remain stable in later biomes and boss fights.
- [ ] Save migration from every released schema version is tested.

## Distribution

- [ ] Codemagic runs tests before archiving.
- [ ] Release archive is signed for App Store distribution.
- [ ] dSYMs and release IPA are retained as artifacts.
- [ ] Build is automatically uploaded to TestFlight.
- [ ] Internal TestFlight group validates every release candidate.
- [ ] External beta review notes explain controls, bosses, ads, and IAP testing.
- [ ] Export-compliance questions answered.
- [ ] Age rating, content rights, and advertising declarations completed.

## Store page

- [ ] Final icon reviewed at all rendered sizes.
- [ ] Name (30-character maximum), subtitle, keywords, and description finalized.
- [ ] Screenshots cover core play, biome variety, bosses, Bugopedia, and customization.
- [ ] Optional preview video uses real captured gameplay.
- [ ] Promotional text and release notes prepared.
- [ ] Privacy policy, support URL, copyright, and contact details are correct.
- [ ] App Review notes describe monetization, restore purchases, and any non-obvious boss mechanics.
