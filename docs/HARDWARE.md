# Hardware scope

Pushwig's core software target is **Ableton Push 3 Controller connected to a normal computer over USB**.

The project also contains optional hardware directions. They are valuable, but they do not define the core visual/controller software and should not confuse a new contributor about what Pushwig is today.

## Current hardware target

The accepted fixture uses:

- Ableton Push 3 Controller;
- its normal external USB controller-mode connection;
- Push's existing audio interface/headphone path;
- an attached macOS host running Bitwig Studio.

The software architecture intentionally keeps this external USB route first-class.

## Optional portable appliance

A later deployment can package the same software with a self-contained Linux host, battery, boot/recovery behavior, and remote desktop access.

The maintainer's available Steam Deck, battery, and angled base form the first appliance fixture. Possible later hosts include Framework or other compact x86 systems.

An appliance is a packaging/deployment project. It does not change the ownership model of the core visual/controller software.

## Optional internal-compute research

A separate research track investigates Push's internal compute bay and Intel NUC Compute Element / CM11EB carrier family.

Useful outcomes may include:

- measured bay/carrier documentation;
- safe passive/active diagnostic edge hardware;
- internal USB/mux/sideband characterization;
- eventual evaluation of a generic Linux compute element inside Push.

Exact electrical/firmware compatibility is unproven until measured. Internal connector work must not be treated as “just USB” or probed casually around power rails.

## Safety

For power/connector experiments:

- identify ground and voltage domains first;
- measure source/sink direction rather than assuming it;
- keep high-current rails isolated by default on development hardware;
- current-limit first power experiments where appropriate;
- preserve differential-pair identity/impedance for high-speed buses;
- use battery chemistry-appropriate charging and protection.

## Detailed research

The existing [`HARDWARE_DOSSIER.md`](HARDWARE_DOSSIER.md) remains the detailed engineering notebook for appliance, battery, bay, CM11EB, and connector work. It is a research reference, not required onboarding for the software project.
