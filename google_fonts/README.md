# Bundled Fonts

The `google_fonts/` directory contains locally bundled Inter typeface files
(`Inter_18pt-*.ttf`, weights 100–900), wired as the `Inter` font family via
the `fonts:` block in `pubspec.yaml`.

## Usage

```dart
TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500)
```

## Licensing

Inter is licensed under the SIL Open Font License 1.1.

- Upstream: https://github.com/rsms/inter
- License text: https://scripts.sil.org/OFL

TODO: vendor the full `OFL.txt` license file into this directory to complete
licensing documentation. The font strategy uses only local assets — no
`google_fonts` package dependency — per `docs/DEPENDENCY_POLICY.md`.
