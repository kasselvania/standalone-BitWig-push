# Remote-slot colors versus DrivenByMoss presentation

September 10, 2026. Controller-only source/API investigation and one existing-setting physical diagnostic. **No new controller behavior, video, or LED policy was implemented.**

Central starting head/tree: `6fe972700c64599e910acd7386c1050cd68fab05` / `6c6a4eed415df972713a0cf11d62f75791ad8700`. Inspected DrivenByMoss head/tree: `a645fcb9e70e4b28a4d7a2ec7f46aaf0f13dfb59` / `a038e0beda4ebccd041c7779573417afb8fea6fa`, containing accepted integration `997158b0a4ddd932a0a985c8b74ffff1e631120f`. Existing untracked native-identity work was left untouched. Installed Bitwig: 6.1.

## Result

There are different color owners, not one shared preference:

| Visible item | Inspected owner/path | Result |
| --- | --- | --- |
| Bitwig remote-slot labels and parameter mapping indications | Existing hardware binding plus `HardwareControl.setIndexInGroup(i)` | Bitwig documents automatic mapping indication from the hardware group index. This is slot/context information, not a permanent color belonging to Speed or Pitch. |
| Push parameter names/values | DrivenByMoss Display Colors → Text → semantic component renderer | One theme text color, not eight per-slot colors. The physical diagnostic changed it. |
| Push buttons' LEDs | Active mode's `getButtonColor` → existing light/MIDI update | Device/page selection and button-function states. They are not currently an eight-encoder mapping palette. |
| Bitwig controller/clip-launcher visualization color | Bitwig controller visualization settings | Separate documented visualization feature; no evidence here that it edits the eight mapping colors. It was not changed. |

The maintainer's controller-popup screenshot shows eight current Sampler remotes in this order: Speed/red, Pitch/orange, Start/yellow, Glide time/bright green, Pan/green-turquoise, Vel Sens./blue, Gain/purple, Output/pink. These are visually observed color families, not measured RGB values. The screenshot does not show a palette editor and is not a physical-LED readback.

The [Bitwig controller manual](https://www.bitwig.com/userguide/latest/midi_controllers/) describes eight colored remote slots, editable assignments/aliases and pages. Bitwig's [controller documentation](https://www.bitwig.com/userguide/latest/default_controller_documentation/) separates script settings from controller visualizations. The [5.0.6 release notes](https://downloads.bitwig.com/5.0.6/Release-Notes-5.0.6.html) describe adjustable controller visualization color; this does not establish an editable remote-slot palette.

## Existing source connections

Paths below are in the inspected DrivenByMoss tree, under `src/main/java/de/mossgrabers/`:

- `controller/ableton/push/PushControllerSetup.java`, `registerContinuousCommands`: registers the eight existing relative encoders, binds their conductive-touch messages and assigns group indices 0–7.
- `controller/ableton/push/mode/device/DeviceParamsMode.java`: uses the current device parameter bank. Activation through `framework/featuregroup/AbstractParameterMode.java` binds the mode provider's parameters to existing knobs; deactivation unbinds them. `bitwig/framework/hardware/HwRelativeKnobImpl.java` calls the existing Bitwig hardware binding and observes its actual target. No new input route is needed to obtain names, formatted values or binding context.
- `framework/parameterprovider/device/BankParameterProvider.java`, `getColor`: returns `Optional.empty()`. It does not currently supply a remote-slot palette.
- `controller/ableton/push/PushConfiguration.java`, `activateDisplayColorSettings`: the global Display Colors settings have individual theme roles, including Text. `bitwig/framework/configuration/ColorSettingImpl.java` receives the Bitwig preference's RGB value. Push setup responds to theme notifications by requesting the active mode's display update.
- `DeviceParamsMode.updateDisplay2` supplies parameter name, numeric/formatted/modulated value and its existing mode-local touch flag. The bottom device/page label uses the selected channel's DAW color. `framework/graphics/canvas/component/ParameterComponent.java` renders parameter text using the theme's `getColorText()`; it does not receive eight remote-label colors.
- `DeviceParamsMode.getButtonColor` gives row 0 orange/yellow/off device/page states and row 1 enabled/visible/expanded/pinned/navigation states. `framework/controller/AbstractControllerSetup.java` routes mode colors into existing lights; the hardware adapter and surface send the corresponding MIDI feedback. `PushColorManager`/`ColorPalette` handle the controller palette, not a queried Bitwig remote palette.

The prior [binding/touch diagnostic](README.md#actual-binding-label-value-and-marker-observations) is still relevant: remote metadata can exist while the encoder is bound to track Volume, and mode-local touch bookkeeping can be stale after a mode transition. A popup label, alias, or color alone is not authoritative proof of the current physical binding. This color investigation does not repair those gaps.

## Public API boundary and independent source precedent

The resolved Maven artifact is `com/bitwig/extension-api/21/extension-api-21.jar`, SHA-256 `eef420a95b1e8c418ee23a5d3969e000413fd5c10432e53a76ede8de31238888`. Inspection used explicit Java 21 `javap`, plus the installed Bitwig 6.1 controller API HTML documentation. These are two identified sources, not an assumption that the current manual and API-21 JAR are identical.

Relevant signatures/findings:

- `HardwareControl.setIndexInGroup(int)` exists in API 21. Its installed documentation says the index automatically determines the mapping indication on the bound parameter (introduced in API 11).
- `RemoteControl` extends `Parameter`; neither exposes a remote-slot palette/color getter in the inspected API. A scan of public color/palette signatures across the JAR found no indexed remote-mapping-color getter.
- `HardwareElement.getLabelColor()` / `setLabelColor(Color)` describe the hardware element's label. They are **not documented as getters/setters for the parameter's mapping indicator**.
- **`LastClickedParameter.parameterColor()` does exist**, returning `ColorValue`. The installed method documentation supplies no color semantics. This is attached to a last-clicked/hovered parameter object, not an indexed set of eight current encoder bindings. Its meaning was not tested; it cannot be substituted for a proven remote mapping-color API. DrivenByMoss's inspected `ModelImpl` only consumes that object's `parameter()` for its focused-parameter wrapper.

Therefore the accurate conclusion is **no documented, verified per-slot mapping-palette readback found**, not “Bitwig has no parameter-color API.” No claim is made that every future API version or undiscovered UI setting lacks one.

Bitwig's own open-source Launch Control XL Mk3 implementation provides a concrete precedent. At commit `a27f2f4b3d9a0e9a71b1d1da10ded02d071275c0`, tree `fe123011a09d257b6add23166a29227e00b6bd03`, [Remotes.java](https://github.com/bitwig/bitwig-extensions/blob/a27f2f4b3d9a0e9a71b1d1da10ded02d071275c0/src/main/java/com/bitwig/extensions/controllers/novation/launchcontrolxlmk3/layer/Remotes.java#L22) declares a fixed eight-color sequence and binds encoder lights using `DEVICE_COLORS.get(i)` (lines 64 and 72). This establishes that implementation's index-based presentation policy, not a universal RGB specification or authority to overwrite Push button-function feedback.

## Physical diagnostic and restoration

The official extension stayed installed throughout, SHA-256 `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`, recomputed unchanged after the investigation. No derivative, new observer, producer, helper application, capture permission change, or JVM-option injection was involved. Bitwig was ordinarily launched for the existing diagnostic; the unsaved project was not closed or discarded.

Only DrivenByMoss **Display Colors → Text** was changed: white `ffffff` to cyan `00ffff`. Asked whether the Push parameter text changed and its physical button LEDs retained their prior colors, the maintainer replied: **“Ah, I had to flip to a new screen for it to refresh, but yes.”** This is the direct physical observation, including its qualification; it is not an immediate-refresh pass. It does not prove an exact triangle RGB match or every controller mode.

The Text preference was restored to `ffffff`; its white swatch and shorthand `fff` were read back in Bitwig. No other color preference was changed. A separate physical confirmation of white after another Push-page refresh has not been supplied. There was no extension swap, so no artifact rollback was required. Bitwig remained available to the maintainer.

The inspected source offers a plausible explanation for the refresh behavior: `AbstractGraphicDisplay.send` compares `ModelInfo`, while a Text-theme change does not change `ParameterComponent`'s equality fields. This is source-consistent with navigation causing a redraw, **not an independently reproduced root-cause proof against the installed official binary**. No redraw repair was made.

## Smallest proposed controller-only improvement

Keep existing Device Parameters names, formatted values, parameter bars and controls. Add a small slot-number/color accent in that existing semantic view, using an explicit eight-slot presentation palette corresponding to the observed Bitwig ordering. The starting display seam is `DeviceParamsMode.updateDisplay2` and its parameter-component presentation, not video ingress or `PushUsbDisplay`.

This would be an explicitly maintained palette, not live synchronization with a user-editable Bitwig palette. It must remain contextual to the current device-parameter binding, handle empty/reassigned slots, and leave Track/Mix and existing button-function LEDs intact. Do not wire it to the undocumented last-clicked color as a shortcut. A change to LED meanings is a separate product decision, not necessary for this first semantic improvement.

This is a recommendation, not implemented/accepted behavior. It does not localize a device control in pixels, solve asynchronous context authority or stale touch bookkeeping, provide new target identity, or qualify a screen feed.

## Verification and custody

Read-only source inspection used `rg`, `sed`, `git rev-parse`, `git status`, `shasum -a 256`, Java 21 `javap`, and GitHub CLI `gh api` for the pinned official Bitwig source. Relevant API checks are reproducible with:

```sh
javap -classpath /path/to/extension-api-21.jar \
  com.bitwig.extension.controller.api.RemoteControl \
  com.bitwig.extension.controller.api.Parameter \
  com.bitwig.extension.controller.api.HardwareControl \
  com.bitwig.extension.controller.api.HardwareElement \
  com.bitwig.extension.controller.api.LastClickedParameter
```

No executable source changed in this continuation; no Java build or physical matrix was rerun. Only this note and its README link are added. No screenshot, proprietary frame, token, project, or complete log is committed.
