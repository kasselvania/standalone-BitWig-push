# Roadmap

The roadmap is ordered by proof dependency, not by the perceived prestige of a fully internal conversion.

The project has several valid success levels:

1. a better Push experience on ordinary Bitwig desktops;
2. a hybrid semantic/visual Push display;
3. a headless, wirelessly manageable Steam Deck appliance;
4. a portable all-in-one using the existing angled base and battery;
5. a reproducible Framework/compact-x86 compute dock;
6. an internal connector development platform;
7. a used NUC Compute Element plus selected battery as the native-bay final form.

A later level does not invalidate or block an earlier one.

## Core software proof track

### S0 — External baseline

**Claim:** the known-good external system is reproducible and measurable.

Reference setup:

- Steam Deck / Linux;
- Bitwig Studio installed via Flatpak;
- Ableton Push 3 Controller over ordinary external USB;
- current compatible DrivenByMoss integration.

Acceptance:

- Bitwig launches reliably;
- Push MIDI/MPE input works;
- transport/encoders/pads function through DrivenByMoss;
- Push audio interface can be enumerated and exercised;
- Push display is working through the existing controller path;
- graphical session and Flatpak permissions are recorded;
- baseline USB/ALSA/PipeWire/device evidence is retained;
- current native plug-in locations and relevant plugdata/serialosc state are inventoried without requiring compatibility work.

### S1 — Independent display ownership

**Claim:** a project-owned compositor can own the Push display without degrading musical control.

Acceptance:

- compositor writes valid 960×160 frames to Push;
- a synthetic layer can be drawn over a semantic/base frame;
- controller input remains functional while frames are sent;
- compositor failure has a defined semantic/recovery fallback;
- frame timing and CPU impact are measured;
- only one process owns the Push display endpoint in steady state.

### S2 — Canonical visual surface

**Claim:** Bitwig can render into deterministic logical geometry independent of the physical monitor or remote client.

Leading experiment: nested gamescope or another controlled GPU-backed surface.

Acceptance:

- Bitwig sees a fixed logical resolution and known UI scale;
- Bitwig child windows and at least one native device/editor behave correctly;
- the surface can be viewed at a different output resolution/aspect ratio without changing source geometry;
- capture obtains stable frames from the surface;
- the backend boundary is documented so gamescope/X11/portal details do not leak into the compositor contract.

### S3 — First Bitwig visual lens

**Claim:** a live native Bitwig UI region can be captured and intelligently embedded on Push.

Acceptance:

- capture service identifies a deterministic Bitwig native-device window or region;
- captured pixels appear inside the Push display at useful legibility;
- semantic controls remain authoritative;
- capture can disappear/reappear without breaking the controller path;
- the adapter declares its canonical source geometry and fallback behavior.

Preferred first target: Bitwig Sampler or another native device with a visually obvious waveform/graph.

### S4 — Plug-in visual lens

**Claim:** arbitrary native Linux plug-in windows can participate in the same visual pipeline.

Acceptance:

- at least one native CLAP or VST3 editor is discovered and captured;
- profile-based crop/fit behavior exists;
- opening/closing the editor is coordinated through Bitwig/DrivenByMoss state where possible;
- no mouse automation is required for ordinary parameter control;
- the profile survives a remote-view output resolution change because its source uses canonical geometry.

### S5 — Headless appliance proof

**Claim:** the Steam Deck can behave as an appliance whose built-in display is unnecessary during ordinary use.

Acceptance:

- boot to the Bitwig/Push stack without manual desktop interaction;
- project can be created/opened, played, recorded and saved from Push for a normal workflow;
- visual and controller services recover from restart;
- a safe shutdown/recovery path exists;
- absence of a remote client does not block ordinary musical operation.

### S6 — Wireless management and portable reference appliance

**Claim:** the existing Steam Deck, battery and wooden base form a portable all-in-one Bitwig Push.

Acceptance:

- full canonical Bitwig desktop accessible over local Wi-Fi from another device;
- modal dialogs and recovery operations are manageable remotely;
- battery powers the host and Push through tested protected paths;
- Push remains directly connected over a stable USB route, even if a dock/hub is required for Deck power distribution;
- cables and hardware are retained/protected by the base;
- representative battery runtime and thermal behavior are measured;
- the remote service is not required for normal musical operation.

S6 is a complete project success, not merely a temporary demo.

## Runtime and plug-in compatibility track

This track runs beside the core display work. It does not block S1–S3.

### R0 — Native Flatpak plug-in baseline

**Claim:** the current Flatpak runtime supports a useful native Linux instrument set.

Acceptance:

- one CLAP and one VST3 load from documented user-visible paths;
- parameters are visible to Bitwig/DrivenByMoss;
- editors open and can be captured;
- project save/reload succeeds;
- Bitwig native devices remain the fallback baseline.

### R1 — plugdata and Monome profile

**Claim:** plugdata/Pure Data and Monome devices are first-class parts of the appliance.

Acceptance:

- `serialosc` discovers the tested grid/arc device on Linux;
- a plugdata or Pure Data patch receives/sends expected OSC state;
- audio/MIDI/OSC routing into the Bitwig workflow is documented;
- plugdata works as CLAP/VST3 or standalone according to the chosen profile;
- boot/reconnect behavior is retained.

### R2 — Non-Flatpak yabridge laboratory

**Claim:** Windows plug-ins can run in a maintainable alternate runtime without destabilizing the primary appliance.

Leading experiment:

```text
SteamOS -> Distrobox/Podman -> Ubuntu 24.04 -> native Bitwig -> Wine Staging/yabridge
```

Acceptance:

- GUI, PipeWire audio and Push USB access work from the chosen boundary;
- at least one Windows VST3 or CLAP plug-in loads and restores;
- plug-in editor capture works;
- xruns, latency and update procedure are characterized;
- projects and user content remain portable between the Flatpak and alternate profiles;
- failure of R2 does not invalidate the native Linux product.

See [`RUNTIME_STRATEGY.md`](RUNTIME_STRATEGY.md).

## Hardware and packaging track

### H0 — Existing base, battery and interconnect survey

**Claim:** the already-owned physical rig can be documented as an engineering platform.

Retain:

- wooden-base internal dimensions and mounting opportunities;
- Steam Deck placement/dock/cable topology;
- battery model, capacity, output profiles and simultaneous-output behavior;
- tested USB-C-to-barrel cable voltage/polarity/current behavior;
- Push/Deck representative power draw;
- airflow and thermal observations;
- safe strain relief and service access.

The existing battery space is energy-storage territory, not generic compute volume.

### H1 — Portable external-port integration

**Claim:** the portable reference appliance can be packaged without opening Push.

Acceptance:

- power, data and charging topology works through the stock rear ports;
- the battery supports representative simultaneous load and play-while-charging behavior where claimed;
- direct Push USB stability is retained;
- the base protects the Deck/compute host, battery and cables;
- the rig can be carried and used without an external wall supply;
- shutdown does not corrupt projects or storage.

### H2 — Push bay and connector survey

**Claim:** the empty standalone bay and carrier can be documented reproducibly.

Retain:

- high-resolution photos;
- PCB and IC markings;
- exact connector family/variant where readable;
- connector geometry, keying and mounting dimensions;
- compute/SSD/thermal/antenna/battery keep-outs;
- accessible continuity points;
- power/mux/hub observations separated from inference.

### H3 — CM11EB development edge card

**Claim:** create a safe, staged development board for the internal connector.

Revision strategy:

- **D0:** passive male edge card exposing grounds, candidate USB 2 pairs and isolated test points; no default power injection;
- **D1:** selectable USB paths, ESD protection, current/voltage observation and explicit VBUS isolation;
- **D2:** only after evidence, controlled-impedance exposure of selected USB 3/PCIe/sideband functions that provide real value.

Acceptance for D0/D1:

- connector geometry is verified before insertion;
- all unneeded power contacts remain disconnected by default;
- USB pair identity/polarity is retained;
- board can be used while Push remains on the existing stand;
- measurements and schematics are public and reproducible.

Do not pretend that routing all 300 high-speed/power contacts onto a cheap two-layer breakout is a safe or useful first board.

### H4 — Internal USB enumeration

**Claim:** the external reference host can enumerate/control Push through the internal compute interface.

Acceptance:

- Steam Deck or another Linux host connects through a reversible development board;
- expected Push USB functions enumerate through the internal path;
- MIDI/control, display and audio tests reproduce the external baseline where electrically available;
- mux/sideband requirements are identified;
- power is handled deliberately rather than by tying VBUS rails together.

This is the key decoupling milestone: if H4 succeeds, a Compute Element is a packaging choice rather than a software requirement.

### H5 — Generic compute and carrier feasibility

**Claim:** define the actual interface contract a replacement host must satisfy.

Compare:

- current Steam Deck;
- Framework mainboard or compact x86 board in the base;
- CM11EB drop-in;
- later NUC-generation modules only where carrier/EC compatibility is evidence-backed.

Score:

- x86-64 + AVX2 compatibility with current Bitwig;
- CPU/RAM performance per watt;
- physical fit and serviceability;
- USB availability;
- NVMe/storage;
- Wi-Fi/networking;
- thermal envelope;
- battery/power-input compatibility;
- recoverability and Linux support;
- used-market economics.

### H6 — Compute Element bring-up

**Claim:** a surplus/used compatible Compute Element can boot the proven Linux/Bitwig stack in Push.

Acceptance:

- Linux boots;
- storage and networking work;
- internal Push hardware enumerates;
- BIOS/carrier/EC requirements are retained;
- thermal behavior is bounded;
- software acceptance tests from S0–S6 can begin running unchanged.

### H7 — Native-bay final form

**Claim:** the used Compute Element, selected battery, charging/power path and thermal system form a serviceable portable instrument.

Acceptance must cover:

- no external compute host;
- battery chemistry and protected pack/BMS behavior;
- charging and play-while-charging transitions;
- low-voltage warning, project save and clean shutdown;
- thermal limits under representative Bitwig load;
- battery replacement/service procedure;
- external recovery path;
- acceptable audio/control/display latency;
- at least the target portable runtime established by H0/H1.

Battery is mandatory for this final form. What remains late is **custom native-bay battery engineering**, not the existence of battery operation in the project.

## Long-term experience work

After the core proofs, improve beyond a conventional Push integration:

- semantic + visual device layouts;
- Sampler waveform and loop visualization;
- native analyzer sidecars: waveform, spectrum, spectrogram, transient and pitch views;
- plug-in visual profiles;
- device-specific visual adapters;
- richer browsing and file management;
- Grid-oriented views;
- plugdata/Pure Data/Monome visual adapters;
- remote tablet editing;
- configurable visual modes and hardware shortcuts;
- user-extensible visual adapters;
- reusable desktop edition for different monitor shapes and resolutions through the canonical visual surface.

The goal is not merely to recreate Ableton standalone behavior with Bitwig. The goal is to exploit Bitwig, Linux, open controllers and an open compositor to make Push a more capable instrument than either stock controller mode or the factory standalone UI.
