# RayGram for iOS

RayGram is an open-source, feature-extended iOS client built upon the official Telegram-iOS codebase. It incorporates client-side privacy enhancements, user interface modernizations, advanced media handling, and deep system-level optimizations designed for Apple Silicon environments.

---

## Key Capabilities

### Privacy and Stealth Architecture
- **Ghost Mode**: Comprehensive suppression of online presence telemetry, automatic offline state transition following message dispatch.
- **Read Receipts Control**: Read receipt suppression with granular per-chat overrides.
- **Typing Status Masking**: Optional masking of typing, audio recording, and video recording activity indicators.
- **Stealth Story Viewing**: Review user stories without broadcasting presence to viewer logs.

### Message Retention and Integrity
- **Anti-Recall Engine**: Local SQLite persistence for deleted incoming messages and media, accompanied by subtle contextual indicators and full deletion management.
- **Expiring Media Preservation**: Prevention of automatic expiration and deletion for self-destructing photos and videos.
- **Message Edit History**: Tracking and inspection of previous message revisions directly within context submenus.

### User Interface and Display
- **System Liquid Glass Aesthetics**: Native translucent glass card rendering for profile headers and sections using Apple system visual effect components with authentic squircle geometry.
- **Pure Pitch-Black AMOLED Theme**: True black (`#000000`) color palette across navigation bars, tab bars, chat backgrounds, and list surfaces, optimized for OLED power conservation and contrast.
- **Dynamic Typography Suite**: Integration with CoreText and system font swizzling, supporting live runtime font switching, custom `.ttf` and `.otf` font file importing, and built-in typographic presets.

### Content Protection and Censorship Bypass
- **Content Restriction Bypass**: Unrestricted access to sensitive channels and 18+ media overlays typically gated on iOS devices.
- **Protected Forwarding Engine**: Unpacking of protected forward-restricted channels and media (`CHAT_FORWARDS_RESTRICTED`), allowing clean quotes and media extraction.
- **Anti-Screenshot DRM Mitigation**: Suppression of screenshot notification events across secret chats and disappearing media, preventing black-canvas screen capture occlusion.

### Local Client Enhancements
- **Client-Side Premium Features**: Access to custom animated emoji statuses, expanded system limits, double folder capacities, high-resolution story playback, and on-device speech-to-text processing via the Apple Speech framework.
- **Account Intelligence**: Exact registration date estimation and account age calculation through chronological Telegram user ID interpolation.

---

## Installation

Precompiled application archives (`.ipa`) are published on the GitHub Releases page with each tagged release.

### Recommended Installation Methods
1. **TrollStore** (iOS 14.0 – 17.0): Provides permanent signing without revocation, supporting extended entitlements and notification services.
2. **AltStore / SideStore**: Weekly self-signing via personal Apple ID.
3. **Sideloadly**: Direct desktop-to-device sideloading with automatic bundle identifier re-signing.

---

## Building from Source

RayGram utilizes the Bazel build system orchestrated via repository-native Python automation scripts.

### Prerequisites
- macOS Sonoma (14.0) or macOS Sequoia (15.0+) running on Apple Silicon.
- Xcode 15.4 or later (configured with Command Line Tools via `xcode-select`).
- Python 3.10+ with standard library modules.
- Bazel 9.x (a validated ARM64 binary is provided in `build-input/`).

### Local Development Build

1. Clone the repository and update submodules:
   ```bash
   git clone --recursive https://github.com/MurKinDev/RayGram-iOS.git
   cd RayGram-iOS
   ```

2. Generate or verify your build configuration:
   ```bash
   cp build-system/appstore-configuration.json build-system/raygram_configuration.json
   ```
   *Note: Populate `api_id` and `api_hash` with your credentials obtained from [my.telegram.org](https://my.telegram.org).*

3. Compile the release application bundle for ARM64:
   ```bash
   python3 -u build-system/Make/Make.py \
     --overrideXcodeVersion \
     build \
     --configurationPath="build-system/raygram_configuration.json" \
     --codesigningInformationPath=build-system/fake-codesigning \
     --configuration=release_arm64 \
     --buildNumber=1
   ```

4. The compiled application package will be output to:
   ```
   build/artifacts/RayGram.ipa
   ```

### Targeted Module Compilation
To verify isolated modular changes without full application linking:
```bash
python3 -u build-system/Make/Make.py \
  --overrideXcodeVersion \
  build \
  --configurationPath="build-system/appstore-configuration.json" \
  --codesigningInformationPath=build-system/fake-codesigning \
  --configuration=release_arm64 \
  --buildNumber=1 \
  --target="//submodules/TelegramUI:TelegramUI"
```

---

## Continuous Integration

RayGram includes a GitHub Actions workflow (`.github/workflows/build.yml`) configured for macOS runners. It automatically:
1. Validates code integrity and dependency graphs.
2. Compiles ARM64 release binaries using remote and local build optimizations.
3. Automatically publishes tagged GitHub Releases with packaged `.ipa` artifacts.

To configure CI in your fork:
1. Navigate to **Repository Settings** > **Secrets and variables** > **Actions**.
2. Define repository secrets:
   - `API_ID`: Your Telegram API application identifier.
   - `API_HASH`: Your Telegram API application secret hash.
3. In **Settings** > **Actions** > **General** > **Workflow permissions**, grant **Read and write permissions**.

---

## Project Structure

```
RayGram/
├── Telegram/                       # Main application target and extensions
│   ├── NotificationService/        # Push notification service extension
│   └── Share/                      # iOS Share extension
├── submodules/                     # Modular Swift / Objective-C libraries
│   ├── TelegramCore/               # Data synchronization, network layer, MTProto
│   ├── TelegramUI/                 # UI components, navigation, and presenters
│   ├── Display/                    # Windowing, animations, font rendering pipeline
│   ├── SettingsUI/                 # RayGram and Telegram settings interfaces
│   └── ScreenCaptureDetection/     # System capture hooks and DRM management
├── build-system/                   # Bazel rules, toolchain scripts, Make.py
└── TODO.md                         # Detailed roadmap and implementation status
```

---

## License and Compliance

RayGram is released under the GNU General Public License v2.0 or later, complying with the open-source licensing requirements of Telegram-iOS.

### Disclaimer
This software is an unofficial, independent modification and is neither affiliated with nor endorsed by Telegram FZ-LLC. All product names, trademarks, and registered trademarks belong to their respective owners. Users are responsible for complying with the Telegram API Terms of Service.
