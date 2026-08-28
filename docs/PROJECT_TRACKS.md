# Project Tracks and Success Boundaries

## Purpose

This project contains related but independent bodies of work. They share a Push/Bitwig contract, but they must not be collapsed into one linear definition of success.

The three primary tracks are:

1. **universal visual/controller integration**;
2. **all-in-one appliance packaging**;
3. **Push internal-connector and native-compute research**.

A fourth category contains optional ecosystem integrations such as Windows plug-in bridging, plugdata, Pure Data, Monome devices, custom analyzers, and other visual sources. Those integrations may use the core interfaces, but they are not prerequisites for the core project.

## Track V — Universal visual/controller integration

This is the primary open-source software product.

Its claim is:

> A Push user can combine DrivenByMoss semantic control with useful live Bitwig/native-device/plug-in visuals without depending on one computer model, one monitor resolution, or one appliance enclosure.

The target is ordinary Bitwig users first:

- desktop and laptop computers;
- arbitrary monitor positions and aspect ratios;
- Linux first, with capture backends designed for later Windows and macOS support;
- Push connected through its normal controller-mode USB contract.

The visual system must support two operating modes:

### Attached mode

Bitwig remains in the user's existing desktop layout. The project discovers windows and visual regions dynamically.

Attached mode must not require:

- a Steam Deck;
- a headless desktop;
- a fixed monitor resolution;
- a forced display profile;
- a project-owned virtual desktop.

### Managed mode

The project controls Bitwig's logical desktop geometry, window placement, or remote-view environment.

Managed mode is useful for:

- headless appliances;
- deterministic automated testing;
- remote-only operation;
- systems where the project is allowed to normalize the whole UI.

A canonical virtual surface is a managed-mode technique. It is not the universal definition of visual portability.

## Track A — All-in-one appliance

This track packages the proven visual/controller software into a portable instrument.

The maintainer's Steam Deck is the first development host because it already exists and proves that the host can be standardized. It is not a project-wide hardware requirement or the only intended appliance computer.

Potential appliance hosts include:

- Steam Deck;
- Framework mainboard;
- compact x86 computer;
- other supported Linux computers.

The first maintainer appliance may use:

- the existing angled wooden stand;
- the existing protected battery;
- Push's stock rear USB port;
- the existing tested USB-C PD-to-barrel power path;
- wireless access to the full Bitwig desktop.

A successful appliance is a major project result, but failure or delay in appliance packaging does not invalidate Track V.

## Track H — Internal connector and native compute

This track investigates Push's Intel NUC Compute Element carrier interface and native-bay final forms.

Independent results include:

- a measured bay/carrier dossier;
- an open CM11EB diagnostic edge card;
- safe internal USB enumeration from an external development host;
- characterization of mux, sideband, power and carrier behavior;
- used Compute Element bring-up;
- native-bay thermal, battery and power integration.

The development edge card is a legitimate open-hardware project even if no final internal NUC conversion is completed.

Track H must not become a prerequisite for Track V or the first Track A appliance.

## Optional ecosystem integrations

The following are adjacent integrations, not core dependencies:

- yabridge/Wine compatibility experiments;
- plugdata and Pure Data;
- Monome grid/arc and serialosc;
- custom analyzers;
- device- or patch-specific visual sources;
- alternative controller integrations.

The maintainer may already have working or experimental versions of these systems. The core repo should expose stable interfaces that allow those projects to participate without taking ownership of their independent roadmaps.

## Valid stopping points

Each of these is a successful deliverable:

1. **visual extension:** adaptive Bitwig/native-device/plug-in visuals mixed with DrivenByMoss on Push for ordinary users;
2. **maintainer appliance:** Steam Deck, battery and existing stand operating as a portable headless Bitwig Push;
3. **reproducible appliance:** documented Framework/compact-x86 packaging that others can reproduce;
4. **connector dev platform:** public CM11EB diagnostic hardware and carrier findings;
5. **native-bay final form:** used Compute Element, battery and validated thermal/power design inside Push.

Later stopping points are larger integrations, not retroactive requirements for earlier ones.

## Repository boundary rule

The current repository may coordinate these tracks while contracts are still forming. When one parallel track develops an independent contributor community, release cadence, safety domain, or build system, split it into a dedicated repository rather than forcing all work into one monolith.

Likely future boundaries:

```text
pushwig-visual          # universal controller/visual software
pushwig-appliance       # reference host, power, boot and packaging profiles
push3-cm11eb-devkit     # connector PCB, carrier research and native-bay tooling
```
