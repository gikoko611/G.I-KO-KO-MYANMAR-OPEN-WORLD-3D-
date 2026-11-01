# G.I KO KO – MYANMAR OPEN WORLD 3D

A Myanmar-inspired, mobile-first 3D open-world life, farming and exploration game.

## Target
- Godot 3.5.2, GLES2
- Android 10+, ARMv7 (armeabi-v7a)
- Designed for low-memory Android devices; compressed/procedural assets and chunk-ready world layout
- APK size target: under 300 MB (must be measured from the actual build)

## Current playable foundation
- Procedural Myanmar countryside: village, rice fields, river, hills, bridge, monastery/stupa landmark
- First-person / third-person camera toggle, sprint, jump and touch-friendly controls with keyboard fallback
- Boy: Myanmar shirt + longyi; Girl: Myanmar blouse + htamein
- Rideable Myanmar water buffalo, traditional two-ox bullock cart, horse, elephant, river boat and rideable Myanmar motorbike
- Rice farming loop: buy seeds and water, go to the rice field, plant crops, water, wait for growth, harvest and sell rice
- Quest progression: meet village elder, harvest rice, sell the required amount and claim a reward
- Expanded countryside props: monastery, stilt house, lotus pond, bamboo grove, village well and rural animals
- Day/night cycle, weather toggle, simple farming/interactions, missions, inventory and local save data
- Character gender and outfit colors selectable in the start screen

## Build
Open with Godot 3.5.2. For Android, install matching export templates and Android SDK/JDK, configure the Android export preset, then export the Android preset.

GitHub Actions workflow: Android ARMv7 Build. It produces a debug APK artifact when the workflow succeeds.

## Important
This is an actively developed game foundation, not a claim of AAA production quality. Replace procedural placeholder meshes with optimized authored assets in later content passes. Always test FPS, memory, touch controls and APK size on the target phone.
