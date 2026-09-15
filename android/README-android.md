Godot Android export notes

Target: Android 7+ (API 24+)

Pre-requirements:
- Install Android SDK (platform tools + platform 33 recommended)
- Install Android NDK (r25 or as recommended by your Godot version)
- Install JDK 11 or as required by Godot (Zulu/OpenJDK)
- Download and install Godot Android export templates matching your Godot version

Steps:
1) In Godot Editor -> Editor Settings -> Export -> Android, set the paths for SDK/NDK/JAR.
2) Project -> Export -> Add Android (AAB recommended).
3) Configure package/identifier (e.g., org.yourname.burmeseopenworld).
4) Sign the export with a keystore (create one if you don't have it):
   keytool -genkey -v -keystore user.keystore -alias user -keyalg RSA -keysize 2048 -validity 10000
5) Export as AAB to reduce download sizes (Play Store will distribute optimized APKs per device).
6) Test on device via adb install (for debug builds) or upload to internal testing track.

Size tips:
- Use compressed textures and atlases.
- Compress audio to OGG Vorbis (mono for SFX, lower bitrate for music loops).
- Strip debug symbols and unused modules.
