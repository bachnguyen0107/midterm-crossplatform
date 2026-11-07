# Temperature Converter: Flutter DevOps and CI/CD Demo
We built a small temperature converter that converts values between Celsius and Fahrenheit and checks user input before performing a conversion. We use it to demonstrate our Flutter development and delivery workflow, including code checks and tests, signed builds for multiple platforms, versioned releases, manual approval before deployment, rollback, failure notifications, and a comparison between GitHub Actions and Codemagic.

## Project links

- **Repository:** https://github.com/bachnguyen0107/midterm-crossplatform
- **Live web version:** https://bachnguyen0107.github.io/midterm-crossplatform/
- **Android release APK:** Available on the GitHub **Releases** page as `app-release.apk`. The APK is also included in the submission package.

## 1. Requirements

- **Flutter:** Stable channel, version 3.47.x. The local development setup used 3.47.0, while CI uses the latest stable version available when the workflow runs.
- **Dart:** Included with the Flutter SDK. The project requires Dart `^3.13.0`, as specified in `pubspec.yaml`.
- **Operating systems:** Windows 10 or 11 for local development and the Windows desktop target; Ubuntu is used by the CI runners.
- **Android:** Android Studio with the Android SDK, Android SDK Command-line Tools, and bundled JDK. The device or emulator must use an `arm64-v8a`, `armeabi-v7a`, or `x86_64` image. Flutter release builds do not support 32-bit x86 emulator images.
- **Web:** Google Chrome or Microsoft Edge.
- **Windows desktop:** Visual Studio 2022 with the **Desktop development with C++** workload. This is only needed for Windows desktop commands and the Windows integration test. The other targets can be used without it.

To check whether the required tools are installed correctly, run:

```bash
flutter doctor -v
```

### Common setup warnings

If `flutter doctor` reports that the Android command-line tools are missing, open Android Studio and go to **Settings → Languages & Frameworks → Android SDK → SDK Tools**. Select **Android SDK Command-line Tools (latest)** and apply the changes.

If the Android license status is unknown, run the following command and accept the license agreements:

```bash
flutter doctor --android-licenses
```

If Flutter cannot find Chrome, you can use Edge with `-d edge`, install Chrome, or set the `CHROME_EXECUTABLE` environment variable to point to your Chromium-based browser.

If Flutter reports that Visual Studio is missing or that it cannot find a suitable Visual Studio toolchain, install Visual Studio 2022 Community and select the **Desktop development with C++** workload. This is only necessary when building or testing the Windows desktop version.

## 2. Getting started

First, clone the repository and move into the project directory:

```bash
git clone https://github.com/bachnguyen0107/midterm-crossplatform.git
cd midterm-crossplatform
flutter pub get
```

You can check which devices and targets Flutter detects by running:

```bash
flutter devices
```

Then start the app on the target you want to use:

```bash
flutter run -d chrome      # Web using Google Chrome
flutter run -d edge        # Web using Microsoft Edge
flutter run -d windows     # Windows desktop; requires the Visual Studio C++ workload
flutter run                # Connected Android device or emulator
```

During local development, the app bar displays `Temperature Converter (dev)`. A release build displays the version taken from its Git tag. For example, a build created from tag `v1.0.2` displays `Temperature Converter (1.0.2)`.

## 3. Running the tests

The project includes unit tests, widget tests, an integration test, static analysis, and a formatting check.

- **Unit tests:** There are six tests in `test/converter_test.dart`. Run them with `flutter test`.
- **Widget tests:** There are four tests in `test/widget_test.dart`. They can also be run with `flutter test`.
- **Integration test:** The end-to-end test is in `integration_test/app_test.dart`. It must run on an actual target, such as Windows desktop or an Android device/emulator. For Windows, use `flutter test integration_test -d windows`. For Android, replace `windows` with the device ID shown by `flutter devices`.
- **Static analysis:** The project uses the rules in `analysis_options.yaml` through `flutter_lints`. Run `flutter analyze` to check the code.
- **Formatting:** Run `dart format --output=none --set-exit-if-changed .` to check whether the files follow Dart formatting rules.

The integration test opens the application and checks a complete conversion flow. It converts 0 °C to 32.00 °F, switches the conversion direction, converts 212 °F to 100.00 °C, and verifies the message shown for invalid input.

This test caught a bug that the widget tests did not. On Windows desktop, after the direction dropdown closes, keyboard focus stays on the dropdown, so `enterText('212')` never reached the input field. The field kept the value `0`, and the app showed -17.78 °C instead of 100.00 °C. All 10 widget tests still passed, because they run in a simulated environment. We fixed the test by tapping the input field again before entering text.

Unlike the unit and widget tests, the integration test needs a real platform target. It cannot be run using plain `flutter test`. On Linux, the test can run without a visible display by using `xvfb-run`. This is also how the `integration.yml` workflow runs it:

```bash
xvfb-run -a flutter test integration_test -d linux
```

## 4. Building release artifacts

### Web

To create the production web build, run:

```bash
flutter build web --release --base-href /midterm-crossplatform/
```

### Android release APK

The release APK must be signed. The keystore used by the project is not stored in this repository. If you want to create a release build locally, generate your own keystore first:

```bash
keytool -genkey -v -keystore release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias release
```

The `keytool` utility is included with the JDK. On Windows, it may not be available directly from `PATH`. In that case, use the copy bundled with Android Studio. The JDK location is also shown in the `Java binary at` entry of `flutter doctor -v`.

For a typical Android Studio installation, the command looks like this:

```bash
"C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -genkey -v -keystore release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias release
```

After creating the keystore:

1. Move `release-key.jks` into `android/app/`. This file is ignored by Git.
2. Copy `android/key.properties.example` to `android/key.properties`.
3. Open `android/key.properties` and enter the values for your own keystore.
4. Build the APK:

   ```bash
   flutter build apk --release
   ```

The generated APK will be located at `build/app/outputs/flutter-apk/app-release.apk`.

A release build intentionally fails if `android/key.properties` is missing. You can still run debug builds with `flutter run` without setting up a release keystore.

### Installing the provided APK

To install the submitted APK, copy `app-release.apk` to an Android phone and open it. Android may ask you to allow installation from unknown apps. You can also install it from a computer with:

```bash
adb install app-release.apk
```
On an emulator, use an `x86_64` or `arm64-v8a` system image. When we first tried the APK on an API 26 x86 emulator, the install failed with `INSTALL_FAILED_NO_MATCHING_ABIS`, because Flutter release builds do not include 32-bit x86 code. Installing on a real phone or an x86_64 emulator works.

If the debug version of the app is already installed, uninstall it before installing the release APK. The two versions use different signing keys, so Android will not install one over the other.

## 5. CI/CD pipeline

The workflow files are stored in `.github/workflows/`.

### Workflows

**CI — `ci.yml`**

This workflow runs when code is pushed to `main` or `develop`, or when a pull request targets `main`. It retrieves the Flutter dependencies, runs static analysis and tests, decodes the signing keystore, builds a signed Android release APK, and uploads the APK as an artifact. A separate job builds the web version and uploads that artifact.

**Notify on CI failure — `notify_failure.yml`**

This workflow starts after the CI workflow finishes. If CI fails, it sends a message to a Discord channel containing the commit, branch, author, and a link to the workflow logs. It does not send a failure notification when CI succeeds.

**Release — `release.yml`**

The release workflow can be triggered by pushing a tag that starts with `v`, or by running the workflow manually with a `tag_name` value. The manual option can also be used when rolling back to an earlier version.

Before publishing, the workflow checks formatting, runs static analysis, and executes the tests. It then waits for manual approval through the `production` environment. Once approved, it builds a signed APK using the version from the tag, creates a GitHub Release containing the APK, builds the web app, and deploys it to GitHub Pages.

**Matrix test — `matrix_test.yml`**

This workflow is started manually. It runs static analysis and tests on `ubuntu-latest` and `windows-latest` at the same time, which helps check that the project behaves consistently across operating systems.

**Integration tests — `integration.yml`**

This is also a manual workflow. It runs the integration test on a Linux desktop target without requiring a visible display.

**Codemagic — `codemagic.yaml`**

This file defines the equivalent build pipeline in Codemagic. It is included for the platform comparison discussed in Section 3 of the report.

### GitHub repository settings

Under **Settings → Secrets and variables → Actions**, add these secrets:

- `KEYSTORE_BASE64`
- `KEYSTORE_PASSWORD`
- `KEY_PASSWORD`
- `KEY_ALIAS`
- `DISCORD_WEBHOOK_URL`

The secret values are not committed to the repository and are masked in workflow logs.

The `production` environment is configured to require at least one reviewer before deployment. Self-review is disabled, and administrators cannot bypass the approval requirement.

The `github-pages` environment only allows deployments from the `main` branch and tags matching `v*`. GitHub Pages is configured to use **GitHub Actions** as its deployment source.

We also use a ruleset on `main`. It requires the `build-and-test` status check to pass before a pull request can be merged.

### Branch and versioning strategy

We work on separate branches and merge changes into `main` through pull requests. The required CI check must pass before a pull request can be merged.

Each release is a new commit on `main` tagged with a Semantic Versioning tag in the format `vMAJOR.MINOR.PATCH`. Two tags must not point to the same commit. We learned this when `v1.0.0` and `v1.0.1` were both created on commit `9aafc1f`: the release workflow succeeded and the uploaded Pages artifact contained 1.0.1, but the live site kept serving 1.0.0. Creating `v1.0.2` on a new commit fixed it.

### Publishing a release

To publish a new version, update the `version:` value in `pubspec.yaml`, commit and push the change to `main`, and wait for CI to pass. Then create and push a version tag. For example:

```bash
git tag v1.0.3
git push origin v1.0.3
```

After the workflow starts, a reviewer must approve the deployment from **Actions → Release → Review deployments**.

### Rolling back the web deployment

To restore an earlier web version, open **Actions → Release → Run workflow**. Under **Use workflow from**, select **Tags** and choose the version you want to restore. Enter that same tag in the `tag_name` field.

After the workflow receives approval, it rebuilds the selected version and deploys it to GitHub Pages. This rollback does not create another GitHub Release.

A browser that has already loaded the site may continue showing the previous version until the Flutter service worker refreshes. You can check the deployed version in a private browsing window.

## 6. Reproducing the main scenarios

### Quality gate blocks a defect

Create a new branch and change `+ 32` to `+ 23` in `lib/converter.dart`. Open a pull request targeting `main`.

The tests should fail during the **Run tests** step. The later build steps are skipped, the pull request cannot be merged because the required check has failed, and a failure notification is sent to Discord.

### Creating a versioned release

Update the app version, commit the change, and push a tag such as `vX.Y.Z`.

The release workflow pauses and waits for approval. After approval, GitHub creates a Release containing `app-release.apk`, and the deployed website displays the matching version number.

### Rolling back a release

Run the Release workflow using an older tag. After approval, the website is deployed with the older version again.

You can check the version in the deployed JavaScript bundle with:

```bash
curl -s <site>/main.dart.js | findstr "Temperature Converter ("
```

On Linux or macOS, replace `findstr` with `grep`. Replace `<site>` with the live web URL listed above.

### Testing on different operating systems

Open **Actions → Matrix test → Run workflow**. The workflow starts two jobs in parallel, one on Ubuntu and one on Windows. Both jobs should complete successfully.

### Comparing build performance

The benchmark results are discussed in Section 3 of the report. The GitHub Actions run uses commit `9ab6793`, while the Codemagic run uses commit `9fbf60e`. The report compares cold-cache and warm-cache timings for each pipeline stage.

## 7. Project structure

```text
lib/
  converter.dart           # Pure conversion functions, covered by unit tests
  main.dart                # UI: input field, direction dropdown, convert button, version label
test/
  converter_test.dart      # 6 unit tests
  widget_test.dart         # 4 widget tests
integration_test/
  app_test.dart            # End-to-end test on a real platform
android/
  key.properties.example   # Template for local release signing; the real file is git-ignored
.github/workflows/         # ci.yml, notify_failure.yml, release.yml, matrix_test.yml, integration.yml
codemagic.yaml             # Codemagic pipeline used for the comparison
```

## 8. Known limitations

- **iOS is not included.** Building and releasing for iOS would require a paid Apple Developer account, macOS runners, and certificate and provisioning-profile management.
- **The CI web job runs independently.** In `ci.yml`, the web job does not depend on the test job. We noticed this in the quality-gate demo: `build-and-test` failed on the `+ 23` defect, but `build-web` still passed and produced a web artifact. The release workflow avoids this because both platform builds depend on the test job.
- **Android rollback has a version-code restriction.** An older APK cannot simply be reinstalled over a newer version because Android rejects a lower version code. To roll back an Android app, a new fixed release must be published with a higher version code.
- **Codemagic uses a separate keystore.** The Codemagic APK is signed with a different key from the GitHub Actions APK, so the two cannot be installed over each other on the same device.
## 9. Third-party components
- `subosito/flutter-action` – installs and caches the Flutter SDK in GitHub Actions.
- `softprops/action-gh-release` – creates GitHub Releases with the APK attached.
- Official GitHub actions: `actions/checkout`, `actions/cache`, `actions/upload-artifact`, `actions/upload-pages-artifact`, `actions/deploy-pages`.
- Dart packages: `flutter_lints` (lint rules) and `integration_test` (end-to-end tests), both from the Flutter SDK.
- The application code was written by the team; no external application template was used.