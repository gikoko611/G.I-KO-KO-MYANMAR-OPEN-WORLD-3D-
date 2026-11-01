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
- Story Chapters 1–2: meet the village elder, farm and trade rice, visit the pagoda, then deliver water to the monastery
- NPC trading: rice sales, seed purchases, paid water purchases and free well refills; proximity checks at village NPCs
- World map panel with player coordinates, nearest landmark marker and mission objective
- Game settings: Low / Balanced / High graphics presets with configurable shadow distance and camera draw distance, mobile MSAA disabled, and music/audio mute toggles
- Original synthesized ambient background music generated locally in-game; no external music download required. Separate sound effects are not implemented yet
- More complete local saves: inventory, currency, quest state, crop growth, weather, time, player position and camera orientation, graphics/audio preferences, and vehicle positions; backup recovery on interrupted saves
- Expanded countryside props: monastery, stilt house, lotus pond, bamboo grove, village well and rural animals with modeled heads, muzzles, ears, legs and tails
- Day/night cycle, weather toggle, animal wandering with lightweight leg gait and idle animation, NPC idle animation, and procedural vehicle body motion
- Animated cart and motorbike wheels that rotate in response to vehicle movement, with parked wheels remaining still
- Corrected wheel spin axes so the cart and motorbike wheels rotate around their axles rather than the wheel faces
- Refined bullock-cart wheel proportions and aligned wheel spin with the local axle axis
- Reduced per-frame environment processing by updating the dynamic sky, fog and sun lighting four times per second
- Adjusted player leg geometry to better align the visible feet with the capsule collision and ground plane
- Refined touch gesture zones so lower-left movement and right-side camera swipes do not overlap the HUD action buttons
- Android workflow now runs a Godot editor/import validation pass before export, then checks APK metadata, signature, ARMv7 native libraries, and absence of ARM64 libraries
- Character gender and outfit colors selectable through in-game HUD buttons

## Build
Open with Godot 3.5.2. For Android, install matching export templates and Android SDK/JDK, configure the Android export preset, then export the Android preset.

GitHub Actions workflow: Android ARMv7 Build (manual workflow dispatch). It exports a debug APK, checks the 300 MB size target, verifies that ARMv7 native libraries are present and ARM64 libraries are absent, and verifies the APK signature before uploading the APK and source ZIP. The current source changes still require a fresh build and runtime validation.

## Important
This is an actively developed game foundation, not a claim of AAA production quality. Replace procedural placeholder meshes with optimized authored assets in later content passes. Always test FPS, memory, touch controls and APK size on the target phone.
