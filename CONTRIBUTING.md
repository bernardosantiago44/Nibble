# Contributing to Nibble

Nibble is a small native macOS app. Keep changes focused, use Apple frameworks where practical, and preserve the local-only processing requirement.

## Branches and pull requests

- Create a short-lived branch from `master` for each change. Use a descriptive prefix such as `feature/`, `fix/`, or `docs/`.
- Open a pull request into `master` and describe the change and its user impact.
- Keep pull requests focused and update the product or design docs when a change affects behavior, architecture, privacy, or the user experience.
- Merge after both required CI checks pass. A review is encouraged, but this solo project does not require an approval count.

## Tests

Run the relevant tests in Xcode before opening a pull request. GitHub Actions runs both targets on macOS for every pull request to `master`:

```sh
xcodebuild test -project Nibble.xcodeproj -scheme Nibble -destination 'platform=macOS' -only-testing:NibbleTests
xcodebuild test -project Nibble.xcodeproj -scheme Nibble -destination 'platform=macOS' -only-testing:NibbleUITests
```

The first command runs unit tests; the second runs UI integration tests. Keep tests focused on useful behavior and regressions.
