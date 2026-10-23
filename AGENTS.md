# Guidelines for AI Agents Working on RayGram-iOS

This repository is **RayGram**, a customized iOS client based on the official Telegram-iOS codebase.
The build system is **Bazel** (`rules_apple` and `rules_swift`), orchestrated via Python scripts under `build-system/Make/`.

To ensure 99%+ build stability and eliminate compilation errors in CI, all agents working in this repository **MUST** adhere to the following rules:

---

## 1. Modular Architecture & Bazel `BUILD` Rules

1. **Every submodule is an isolated compilation unit (`swift_library`):**
   - Code inside `submodules/Path/To/Module` can only see symbols from other modules if those modules are explicitly listed in `deps = [...]` inside that module's `BUILD` file.
2. **Never import a module without updating `BUILD`:**
   - If you write `import Foo` in any `.swift` file, you **MUST** ensure `"//submodules/Foo"` (or its exact Bazel target path) is present in the `deps` list of that module's `BUILD` file.
   - Example: Using `StoreMessage` requires `import Postbox` in Swift AND `"//submodules/Postbox"` in the target `BUILD` file.
3. **Compiler flags (`-warnings-as-errors`):**
   - All warnings are treated as hard errors. Never leave unused variables, unreachable code, or unhandled enum cases.

---

## 2. API Signature & Type Verification

1. **Never guess API signatures from memory:**
   - Telegram has thousands of helper functions with similar names across different modules (e.g., `textAlertController` in `Display` vs `PresentationDataUtils`).
   - Before calling an API, use `grep` or `view_file` to locate its exact declaration and verify all parameter names, labels, and types.
2. **Check for Overloads:**
   - For example, `textAlertController(...)` in `PresentationDataUtils` accepts `String` titles and texts, while `Display.textAlertController(...)` requires `NSAttributedString` and `AlertControllerTheme`. If `PresentationDataUtils` is omitted from `import`, the compiler falls back to the wrong overload and fails with confusing type errors.
3. **Controller Inheritance & Downcasting:**
   - Many component screens wrap standard `ViewController` instances. If a method or closure is specific to a subclass (such as `parentController()` on `GiftOptionsScreen`), you must downcast `controller as? ConcreteControllerClass` before calling the method.

---

## 3. Targeted Local Module Compilation (Bazel)

Full build of the Telegram application produces an IPA with hundreds of submodules, C/C++ libraries (WebRTC, FFmpeg, BoringSSL), app extensions, and code signing. On CI or locally without remote cache, a full build can take 60–90 minutes.

However, **Bazel is a granular graph build system**. Every submodule is an independent target (`swift_library`). You do **not** need to build the full app to verify your code. You can compile only the exact module you edited!

### Why Targeted Compilation is Crucial:
- **`swiftc -parse <file>` is NOT enough:** It only checks grammar. It does **not** check imports, types, or dependencies.
- **Targeted Bazel compilation is 100% accurate:** It invokes `swiftc` with all dependencies, `-warnings-as-errors`, search paths, and module maps. If it compiles locally, CI will compile it too.
- **Speed:** Compiles in a few seconds/minutes instead of an hour.

### How to Run Targeted Compilation:

1. **Find the Bazel target for the modified file:**
   - Look at the `BUILD` file in the same directory (or parent directory) of the file you modified.
   - Example: For `submodules/TelegramUI/Components/Gifts/GiftOptionsScreen/Sources/GiftOptionsScreen.swift`, the target is:
     `//submodules/TelegramUI/Components/Gifts/GiftOptionsScreen:GiftOptionsScreen`

2. **Execute targeted compilation:**
   Run via the repository's `Make.py` with the `--target` flag:
   ```bash
   python3 -u build-system/Make/Make.py \
     --overrideXcodeVersion \
     build \
     --configurationPath="build-system/appstore-configuration.json" \
     --codesigningInformationPath=build-system/fake-codesigning \
     --configuration=release_arm64 \
     --buildNumber=1 \
     --target="//submodules/TelegramUI/Components/Gifts/GiftOptionsScreen:GiftOptionsScreen"
   ```
   Or query targets using the local Bazel binary:
   ```bash
   ./build-input/bazel-9.2.0-darwin-arm64 query "//submodules/TelegramUI/Components/Gifts/GiftOptionsScreen:*"
   ```

---

## 4. Strict Pre-Commit Verification Checklist

Before creating a git commit or pushing to `origin/master`:

1. **Inspect `git diff` Line-by-Line:**
   - Scan all newly introduced symbols, classes, structs, enums, and protocols.
   - Verify every `import` corresponds to a dependency in the target `BUILD` file.
   - Verify every function/initializer call matches the actual signature in the codebase.
2. **Compile the modified module locally** (following Section 3) whenever significant logic or new dependencies are added.
3. **Optional Subagent Cross-Check:**
   - For non-trivial changes, invoke a `research` subagent to act as a strict code reviewer on the diff, specifically auditing:
     - Missing `BUILD` dependencies
     - Missing imports
     - Type mismatches
     - Potential retain cycles or threading issues (e.g., ensuring UI updates are on `Queue.mainQueue()`)

---

## 5. Git & CI Build Guidelines

1. **Conventional Commits:**
   - Use structured commit messages: `feat(...)`, `fix(...)`, `docs(...)`, `refactor(...)`.
2. **Triggering CI Builds:**
   - Pushing to `origin/master` immediately triggers the GitHub Actions CI workflow (`.github/workflows/build.yml`), which builds the release ARM64 IPA on an Apple Silicon runner.
   - Never push unverified code to avoid wasting runner minutes and developer time.
3. **Documentation:**
   - Maintain and update [TODO.md](file:///Users/macbook/Projects/RayGram/TODO.md) whenever new features, bug fixes, or roadmap items are requested.
