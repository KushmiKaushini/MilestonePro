# Milestone Pro Gradle (KTS) Audit Report

**Date:** April 9, 2026  
**Build System:** Gradle (Kotlin DSL)

## 1. Stack Versioning
The project uses an extremely modern (bleeding-edge) Android build stack:
- **Gradle:** `8.14`
- **Android Gradle Plugin (AGP):** `8.11.1`
- **Kotlin:** `2.2.20`
- **JDK:** `17`

### 🟢 Strengths
- **Performance:** Gradle 8.x and AGP 8.x provide significant build speed improvements and better resource shrinking.
- **Future-Proof:** Adopts the latest Kotlin patterns and build features.
- **Desugaring:** Correctly implements `isCoreLibraryDesugaringEnabled` for compatibility with older Android devices while using modern Java APIs.

---

## 2. Custom Build Logic Analysis

### 🟡 Manifest Sanitizer Task (`build.gradle.kts:35-49`)
The project contains a custom task that automatically removes the legacy `package=` attribute from subproject (plugin) `AndroidManifest.xml` files during the build process.
- **Why it's there:** AGP 8+ requires the namespace to be defined in `build.gradle` rather than the manifest. Many older Flutter plugins still have the manifest attribute, causing build failures.
- **Risk:** This logic modifies external files (often in the global `pub-cache`). While it solves the build error, it is a non-standard "hotfix" that may cause unexpected behavior if those files are expected to be immutable.

### 🟡 Namespace Enforcement (`build.gradle.kts:31-33`)
Automatically generates a namespace for plugins that lack one. This is a good safety measure for maintaining build stability with diverse plugin ecosystems.

---

## 3. Configuration Observations

### 🔴 Application Identity
- **Issue:** `applicationId` and `namespace` are set to `com.example.milestone_pro`.
- **Recommendation:** Change this to a unique production ID (e.g., `com.yourdomain.milestonepro`) before release. This is critical for Play Store publishing and deep-linking.

### 🟢 Build Dir Relocation
The build directory is redirected to `../../build`. This is a common pattern in Flutter to keep the `android/` directory clean and works well here.

---

## 4. Recommendations

1. **Rename Package:** Prioritize changing the `applicationId` from `com.example` to a unique identifier.
2. **Plugin Monitoring:** Because the stack is so new (`Kotlin 2.2`, `AGP 8.11`), monitor for "Symbol not found" errors in third-party plugins. Some plugins may not be compatible with Kotlin 2.2 yet.
3. **Formalize Sanitizer:** Consider moving the "Manifest Sanitizer" logic into a separate Gradle script if it grows more complex, or document it clearly in the README so other developers aren't surprised by build-time file modifications.
