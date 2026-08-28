# Roadmap

The roadmap is ordered by proof dependency, not by excitement. A later hardware milestone does not block an earlier software milestone.

## Software proof track

### S0 — External baseline

**Claim:** the known-good external system is reproducible and measurable.

Reference setup:

- Steam Deck / Linux;
- Bitwig Studio installed via Flatpak;
- Ableton Push 3 Controller over ordinary external USB;
- current DrivenByMoss Push 3 integration.

Acceptance:

- Bitwig launches reliably;
- Push MIDI/MPE input works;
- transport/encoders/pads function through DrivenByMoss;
- Push audio interface can be enumerated and exercised;
- Push display is working through the existing controller path;
- baseline USB/ALSA/PipeWire/device evidence is retained.

### S1 — Independent display ownership

**Claim:** a project-owned compositor can own the Push display without degrading musical control.

Acceptance:

- compositor writes valid 960×160 frames to Push;
- a synthetic layer can be drawn over a semantic/base frame;
- controller input remains functional while frames are sent;
- compositor failure has a defined recovery path;
- frame timing and CPU impact are measured.

### S2 — First Bitwig visual lens

**Claim:** a live Bitwig UI region can be captured and intelligently embedded on Push.

Acceptance:

- capture service identifies a deterministic Bitwig/native-device window or region;
- captured pixels appear inside the Push display at useful legibility;
- semantic controls remain authoritative;
- capture can disappear/reappear without breaking the controller path.

Preferred first target: Bitwig Sampler or another native device with a visually obvious waveform/graph.

### S3 — Plug-in visual lens

**Claim:** arbitrary plug-in windows can participate in the same visual pipeline.

Acceptance:

- at least one VST/CLAP editor is discovered and captured;
- profile-based crop/fit behavior exists;
- opening/closing the editor is coordinated through Bitwig/DrivenByMoss state where possible;
- no mouse automation is required for ordinary parameter control.

### S4 — Headless appliance proof

**Claim:** the Steam Deck can behave as an appliance whose built-in display is unnecessary.

Acceptance:

- boot to the Bitwig/Push stack without manual desktop interaction;
- project can be created/opened, played, recorded and saved from Push for a normal workflow;
- visual services recover from restart;
- a safe shutdown/recovery path exists.

### S5 — Remote desktop and management

**Claim:** exceptional desktop tasks can be handled remotely without compromising the Push-first workflow.

Acceptance:

- full Bitwig desktop accessible over local Wi-Fi from another device;
- recovery remains possible when a modal dialog appears;
- remote service is not required for normal musical operation.

## Hardware proof track

Hardware milestones may begin once useful measurements can be taken, but they must not replace S0–S3 as the project’s first proof path.

### H0 — Controller bay survey

**Claim:** the empty standalone bay and carrier can be documented reproducibly.

Retain:

- high-resolution photos;
- PCB and IC markings;
- connector geometry and keying;
- mounting dimensions;
- empty SSD, thermal, antenna and battery areas;
- accessible continuity points.

### H1 — Carrier USB map

**Claim:** the internal compute carrier path to Push hardware can be mapped against the documented Intel CM11EB edge connector.

Acceptance:

- candidate USB differential pair(s) identified;
- continuity and ground reference recorded;
- power direction/rail assumptions explicitly separated from confirmed facts;
- no unverified power injection.

### H2 — Internal USB breakout

**Claim:** the external reference host can enumerate/control Push through the internal compute interface.

Acceptance:

- Steam Deck or another Linux host connects through a reversible breakout;
- expected Push USB functions enumerate through the internal path;
- MIDI/control and display tests reproduce the external baseline where electrically available;
- power is handled deliberately rather than by blindly tying VBUS rails together.

This is the key decoupling milestone: if H2 succeeds, a CM11EB Compute Element is a packaging option rather than a fundamental requirement.

### H3 — Generic compute feasibility

**Claim:** define the actual interface contract an internal computer must satisfy.

Decide between:

- CM11EB drop-in;
- alternate x86 board with carrier breakout;
- other future host architectures if Bitwig support permits.

### H4 — Compute Element bring-up

**Claim:** a surplus/used compatible Compute Element can boot our Linux stack in Push.

Acceptance:

- Linux boots;
- storage and networking work;
- internal Push hardware enumerates;
- thermal behavior is bounded;
- software acceptance tests from S0–S5 can begin running unchanged.

### H5 — Internal Pushwig

**Claim:** the proven external appliance becomes physically self-contained in Push.

Acceptance:

- no external compute host required;
- ordinary Bitwig workflow survives reboot;
- recovery path remains available;
- acceptable audio/control/display latency under representative project load.

### H6 — Appliance polish

Thermals, boot UX, watchdogs, storage management, networking, update strategy, diagnostics and robust shutdown.

### H7 — Battery operation

Battery and charging are explicitly last because they introduce a separate safety and power-management problem.

Acceptance must cover pack chemistry, BMS behavior, charging, low-voltage handling, thermal limits, clean shutdown and fault recovery before calling battery operation supported.

## Long-term experience work

After the core proofs, improve beyond a conventional Push integration:

- semantic + visual device layouts;
- Sampler waveform and loop visualization;
- native analyzer sidecars (waveform, spectrum, spectrogram, transient/pitch views);
- plug-in visual profiles;
- device-specific visual adapters;
- richer browsing and file management;
- Grid-oriented views;
- remote tablet editing;
- configurable visual modes and hardware shortcuts;
- user-extensible visual adapters.

The goal is not merely to recreate Ableton standalone behavior with Bitwig. The goal is to exploit Bitwig, Linux and an open compositor to make Push a more capable instrument than either stock controller mode or the factory standalone UI.