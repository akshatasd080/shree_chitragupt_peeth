# Shree Chitragupt Peeth

Official Flutter app for **Shree Chitragupt Peeth**, Vrindavan  
Android package: `org.shreechitraguptpeeth.app`

## Run locally

```bash
flutter pub get
flutter run
```

API environment is controlled in `lib/core/constants/api_config.dart` (`Environment.prod` / `local`).

## Google Play release

See **[store/PLAY_STORE.md](store/PLAY_STORE.md)** for the full publishing checklist.

Quick release build:

```bash
# 1) Create android/key.properties from android/key.properties.example
# 2) Host store/legal/*.html on your website
flutter build appbundle --release
```

## Legal pages to host

- `store/legal/privacy-policy.html`
- `store/legal/terms.html`
- `store/legal/delete-account.html`
