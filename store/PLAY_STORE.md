# Google Play Store — Publish Guide

App: **Shree Chitragupt Peeth**  
Package ID: `org.shreechitraguptpeeth.app`  
Version in `pubspec.yaml`: `1.0.0+1` (`versionName` + `versionCode`)

## Before you upload (must-do)

### 1. Host legal pages (Play policy blockers)

Upload the HTML files from `store/legal/` to your website so these URLs work (they are already referenced in the app):

| File | Public URL |
| --- | --- |
| `privacy-policy.html` | https://www.shreechitraguptpeeth.org/privacy-policy |
| `terms.html` | https://www.shreechitraguptpeeth.org/terms |
| `delete-account.html` | https://www.shreechitraguptpeeth.org/delete-account |

**Important:** The current `/privacy-policy` URL on the website does not show a real privacy policy. Play Console will reject or flag the listing until a real policy page is live.

### 2. Create a release keystore (once)

```bash
keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Copy `android/key.properties.example` → `android/key.properties` and fill passwords/paths.  
Never commit `key.properties` or `*.jks`.

### 3. Backend account deletion

The app calls `DELETE` / `POST` `https://shreechitraguptpeeth.org/api/auth/delete-account` with the user Bearer token.

- Implement that endpoint on your API so in-app deletion completes immediately, **or**
- Keep the web/email deletion path live (already provided) — Play accepts a working request flow, but users should get actual data deletion after the request.

### 4. Build the Play upload (AAB)

```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

Optional obfuscation (recommended for production):

```bash
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols
```

Keep the `build/symbols` folder privately for crash deobfuscation.

## Play Console checklist

1. Create app → set default language (English / Hindi as needed)
2. App access / content rating questionnaire
3. Target audience & news apps declarations (if prompted)
4. **Data safety** form — use answers below
5. **Privacy policy URL** — live privacy page
6. **Account deletion URL** — live delete-account page
7. Store listing assets (see `store/listing/`)
8. Upload AAB to Internal testing → closed → production
9. Use Play App Signing (recommended; upload key = your keystore)

## Suggested Data safety answers

Collected / shared for app functionality (account + forms):

| Data type | Collected | Shared | Purpose |
| --- | --- | --- | --- |
| Name | Yes | No (unless required by temple ops tooling you control) | Account |
| Email | Yes | No | Account / contact |
| Phone | Yes | No | Account / contact |
| Other user content (form messages) | Yes | No | Bookings / donations / contact |
| App interactions / crash diagnostics | Optional / if you add analytics later | — | — |

- Data encrypted in transit: **Yes** (HTTPS)
- Users can request deletion: **Yes**
- Account deletion URL: `https://www.shreechitraguptpeeth.org/delete-account`

Photos / videos: the app may **write** downloaded media to the gallery; it does **not** request `READ_MEDIA_IMAGES` / `READ_MEDIA_VIDEO`.

## Permissions declared

- `INTERNET`
- `WRITE_EXTERNAL_STORAGE` (maxSdkVersion 29 only, for older Android gallery save)

## Store listing copy

See `store/listing/store-listing.txt`.

## Graphics you still need to create

| Asset | Size |
| --- | --- |
| App icon (Play) | 512 × 512 PNG |
| Feature graphic | 1024 × 500 PNG |
| Phone screenshots | at least 2 (preferably 4–8) |
| Optional 7" / 10" tablet screenshots | if you claim tablet support |

Export screenshots from a real device or emulator after login.
