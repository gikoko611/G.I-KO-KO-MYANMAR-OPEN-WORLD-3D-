# G.I KO KO — MYANMAR OPEN WORLD 3D

<p align="center">
  <strong>Explore • Build • Farm • Survive • Live Your Story</strong><br>
  <em>Powered by I KO KO</em>
</p>

A Myanmar-inspired 3D open-world life simulation and survival RPG for Android. Explore rural villages, work for a living, grow crops, trade resources, discover hidden places, build relationships and choose your own path.

> **Project status:** Active development. Features listed below describe the current source implementation; visual polish, device performance and gameplay behavior still require testing on physical Android hardware.

## Project links

- **GitHub repository:** https://github.com/gikoko611/G.I-KO-KO-MYANMAR-OPEN-WORLD-3D-
- **Developer GitHub profile:** https://github.com/gikoko611
- **Facebook:** [G.I KO KO — Facebook update](https://www.facebook.com/1194405357098288_122123590029411562)
- **Public contact email:** `ADD_PUBLIC_GMAIL_ADDRESS_HERE`

The Facebook link currently points to a shared Facebook post. Replace it with the official Facebook Page/Profile URL when the public page link is confirmed. Replace the email placeholder with an address intended for public contact.

## Target platform

| Component | Target |
|---|---|
| Engine | Godot 3.5.2 |
| Renderer | GLES2 |
| Platform | Android 10+ |
| CPU ABI | Universal APK: ARMv7, ARM64, x86 and x86_64 (if supported by export templates) |
| Device focus | Redmi 9A-class entry-level Android devices |
| Build | GitHub Actions Android debug APK |
| Orientation | Landscape |

The Android build is configured as a multi-ABI package for ARMv7, ARM64, x86 and x86_64 devices, subject to native library support in the matching Godot export templates. Android selects a compatible native ABI at install/runtime. The project favors procedural low-poly geometry and MultiMesh batching to reduce asset size and draw-call overhead. Actual FPS, memory use, thermal behavior, GPU compatibility and battery use must be measured on target devices.

## World and exploration

- Large procedural countryside map with 12 named Myanmar-inspired villages.
- Approximately 1,200 low-poly house visuals generated in batches.
- Village roads, bridges, canals, rice fields, hills, forests, a lake, waterfall, cave and hidden treasure locations.
- Collectible coins, gems, treasure and fruit trees.
- Day/night lighting and weather variation.
- First-person and third-person camera modes, walking, sprinting, jumping, swimming, diving and tree climbing prototypes.
- Rideable vehicles include motorcycle, bullock cart, buffalo, horse, elephant and boat.

### Enterable buildings

The interior system adds door-based entry and exit for:
- One sample house in each of the 12 villages.
- A market interior in each of the 12 villages.
- The monastery.
- A Myanmar school classroom.
- A pagoda prayer hall.
- The hidden cave.

Approach an entrance and press **Interact** to enter. Press **Interact** again while inside to return outside. The 1,200 house visuals are not all individually enterable; the current implementation provides representative enterable homes in each village. Interior rooms use lightweight procedural geometry.

## Life simulation and survival

- Choose a Boy or Girl character with Myanmar-inspired clothing.
- Start as a stranger and build a new life around the monastery and villages.
- Gather wood, bamboo, stone, fiber, herbs and ore; fish, hunt and collect fruit.
- Plant, water and harvest rice.
- Sell gathered resources and valuables; buy seeds, tools, fishing gear, medicine and equipment.
- Basic XP, levels and skill progression across farming, hunting, woodcutting, fishing, mining, crafting and combat.
- Companion character with Follow, Work and Rest modes; the companion can provide limited gathering and hunting bonuses.
- Branching story choices for a family route or a hermit route.
- Crafting, inventory, missions, save/load, day/night and weather systems.

Some life-simulation systems are prototypes rather than full real-world simulations. For example, family progression is currently represented by story state and does not yet provide a complete spouse/children NPC system. Combat gear and skill effects also require further balancing and runtime verification.

## Controls

- Left-side touch joystick: movement.
- Right-side touch area: camera look.
- Action buttons: Interact, Jump, Sprint, Ride, View, Gather, Fish, Hunt, Craft, Plant, Water, Harvest, Market, Buddy, Dive, Climb, Fruit, Story and other actions.
- **Interact at a marked entrance** to enter a building; interact again to exit.
- Boy/Girl selection is available from the character controls.

The current HUD has many action buttons. Layout, touch target size and usability need validation on different phone aspect ratios before release.

## Device compatibility

The goal is broad Android compatibility, not a guarantee for every phone model. The universal package includes multiple CPU ABIs so older 32-bit ARM devices and modern 64-bit ARM devices can be supported. Very old Android releases, unsupported GPUs, vendor-specific graphics drivers, low available RAM and unusual screen aspect ratios may still prevent installation or smooth gameplay. The actual minimum Android SDK is confirmed from APK metadata during CI validation.

The game uses GLES2, includes Low/Balanced/High graphics choices, and scales touch HUD offsets and control sizes for different landscape screen dimensions. Start with Low on entry-level devices and raise quality on stronger phones.

## Build from source

1. Install **Godot 3.5.2** and its matching export templates.
2. Open the repository project in Godot.
3. Configure the Android export template and Android SDK/JDK for Godot 3.
4. Select the Android ARMv7 export preset.
5. Export a debug APK, or use the repository's GitHub Actions workflow.

### GitHub Actions

Workflow: `.github/workflows/android-build.yml`

The workflow performs GDScript/import validation, exports a universal Android debug APK, checks APK metadata and signature, verifies native libraries for every configured ABI, then uploads build artifacts when successful.

Run status and artifacts:  
https://github.com/gikoko611/G.I-KO-KO-MYANMAR-OPEN-WORLD-3D-/actions

## Development roadmap

- Improve interior room detail, doors, furniture interaction and NPC schedules.
- Add a more complete school/learning loop, household needs, cooking and personal-care activities.
- Expand marriage, family and companion storylines with interactable NPCs.
- Add shopkeeper NPCs, item-by-item trading UI and live-animal trading where appropriate.
- Improve equipment visuals, combat feedback, skill effects and mission pacing.
- Optimize world visibility, level-of-detail and collision for low-memory ARMv7 phones.
- Test touch UI, save/load, FPS, memory, APK size and thermal performance on Redmi 9A.

## Credits and contact

**Developer:** G.I KO KO  
**Branding:** Powered by I KO KO  
**Source:** https://github.com/gikoko611/G.I-KO-KO-MYANMAR-OPEN-WORLD-3D-  
**Facebook update:** https://www.facebook.com/1194405357098288_122123590029411562  
**Email:** `ADD_PUBLIC_GMAIL_ADDRESS_HERE`

## License

No license has been added yet. Unless a license file is added, all rights remain with the repository owner and reuse/redistribution permissions are not automatically granted.
