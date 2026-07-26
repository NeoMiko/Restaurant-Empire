# Google Play Release Checklist

Status date: 2026-07-26. This checklist separates work already prepared from publisher decisions and Play Console actions that cannot be completed from source code alone.

## Prepared in the project

- [x] Landscape layout and touch/mouse-compatible controls.
- [x] Android APK exports and runs in an emulator (confirmed by project owner).
- [x] Compatibility renderer suitable for a mobile 2D prototype.
- [x] Save on important actions, autosave, background notification and clean shutdown.
- [x] Local-only prototype: no accounts, ads, analytics, telemetry, cloud services or in-app purchases found.
- [x] Unused `INTERNET`, `ACCESS_NETWORK_STATE` and `ACCESS_WIFI_STATE` permissions disabled.
- [x] Godot MIT notice included in documentation and accessible in the game.
- [x] Privacy policy draft and Data safety answers prepared.
- [x] Gacha uses earned gameplay tickets only; displayed odds are Common 70%, Rare 20%, Epic 7%, Legendary 2.5%, Mythic 0.5%.
- [x] Automated core, scene-loading and restaurant-loop tests available.

## Publisher decisions required

- [ ] Choose and verify the legal publisher/developer name.
- [ ] Supply a monitored support/privacy e-mail address.
- [ ] Replace `com.restaurantempire.prototype` with a final, controlled, globally unique package ID. This ID cannot be changed for an existing Play listing.
- [ ] Decide whether the game project itself remains under the repository's current MIT License or becomes proprietary. Godot remains MIT either way.
- [ ] Search the game title and visual identity in relevant trademark databases, including EUIPO, before spending on branding: https://www.euipo.europa.eu/en/search-ip
- [ ] Decide target countries, languages and target age group. If children are included, complete the Families requirements before release.

## Privacy policy and Data safety

- [ ] Fill all `[TO COMPLETE]` fields in `docs/PRIVACY_POLICY_DRAFT.md`.
- [ ] Publish the policy on a public HTTPS webpage: no login, no geoblocking, not a PDF, not user-editable.
- [ ] Replace the in-app placeholder contact and URL in `scripts/ui/legal.gd`.
- [ ] Enter the same URL in Play Console.
- [ ] Re-audit the final signed AAB and all SDKs before answering Data safety.

Proposed Data safety answers for the current audited build:

- Does the app collect or share required user-data categories? **No.**
- Is all user data encrypted in transit? **Not applicable: no user data is transmitted.** Answer according to the exact wording currently shown by Play Console.
- Can users request deletion? **No remote data exists.** Explain in the policy that clearing app data or uninstalling deletes the local save.
- Ads? **No.**
- Account creation? **No.**

These are draft answers, not an automatic submission. Any analytics, crash reporting, advertising, login, cloud save, social, payment or network SDK changes them.

Google's current User Data policy requires every app to provide a privacy policy, including apps that do not access personal and sensitive data: https://support.google.com/googleplay/android-developer/answer/10144311

## Content rating and randomized rewards

- [ ] Complete the IARC questionnaire truthfully for the exact shipped content.
- [ ] Declare simulated restaurant economy and randomized employee recruitment where the questionnaire asks about chance-based mechanics.
- [ ] Keep published rarity odds visible near recruitment and update them whenever balance data changes.
- [ ] Do not introduce purchases of randomized rewards without a separate policy/legal review.

Content-rating guidance: https://support.google.com/googleplay/android-developer/answer/9898843

## Android release build

- [ ] Confirm the target API immediately before upload. Current Google schedule requires new apps/updates to target Android 15 / API 35; from 31 August 2026 the requirement moves to Android 16 / API 36: https://support.google.com/googleplay/android-developer/answer/11926878
- [ ] Install matching Godot Android export templates, Android SDK/platform/build tools and JDK on the release machine.
- [ ] Create a release keystore outside the repository, back it up securely and record passwords in a password manager. Never commit it.
- [ ] Export a signed **AAB** for Play rather than distributing the debug APK.
- [ ] Review the final merged Android manifest and requested permissions.
- [ ] Enable Play App Signing and keep the upload key recoverable.
- [ ] Increment version code for every upload and use a user-facing semantic version name.

## Verification before production

- [ ] Run all automated tests after the final export configuration change.
- [ ] Test install, launch, suspend/resume, save/load, offline reward and Android Back on at least one physical low/mid-range device.
- [ ] Test an upgrade from the previous signed build without losing save data.
- [ ] Test fresh install and corrupted-save recovery.
- [ ] Inspect UI at several landscape aspect ratios and with system font/display scaling.
- [ ] Confirm there is no debug panel, test currency shortcut or verbose logging in the production feature set.
- [ ] Confirm the final AAB contains only owned/licensed assets and updated third-party notices.

## Play Console listing

- [ ] Create app record, select Game and appropriate category.
- [ ] Add app name, short description, full description, icon, feature graphic and phone/tablet screenshots.
- [ ] Add support e-mail and optional website.
- [ ] Complete App access, Ads, Data safety, Content rating, Target audience, News apps and other required declarations.
- [ ] Upload first to Internal testing, review the pre-launch report, then Closed testing before Production.
- [ ] Check current personal-developer testing requirements in the specific Play Console account.

The project is technically prepared for continued Android testing, but it is not publication-ready until all unchecked release blockers are resolved.
