# Native Bitwig device × DrivenByMoss behavior matrix

This is the first maintained product-design catalog for [issue #47](https://github.com/kasselvania/standalone-BitWig-push/issues/47).

It joins three different facts that must not be confused:

1. what Bitwig says a native device is and what workflows it exposes;
2. what the current DrivenByMoss Push manual and accepted source expose through generic Device/Browse modes;
3. what Pushwig might deliberately redesign for a useful Push-native visual experience.

The machine-sortable inventory is [`native-device-behavior-matrix.csv`](native-device-behavior-matrix.csv).

## Scope

This first pass covers **151 top-level native devices** from Bitwig's Device Descriptions reference, with the Bitwig Studio 6.1 `Tuner` addition included from the official 6.1 Quick Guide.

It intentionally does not flatten these larger domains into the same table yet:

- individual modulators;
- the hundreds of Grid modules;
- third-party VST/VST3/CLAP devices;
- every browser source and insertion context.

The three top-level Grid devices are included because they are ordinary device-chain objects; their internal module inventories are not.

## Reference set

The exact manual references and one-command local fetcher live in [`../reference/manuals/`](../reference/manuals/).

Reference IDs used by the CSV:

| ID | Meaning |
|---|---|
| `BW-D19` | Official Bitwig Studio User Guide, Device Descriptions appendix, retrieved 2026-09-02. |
| `BW-Q61` | Official Bitwig Studio 6.1 Quick Guide supplement. Required for the redesigned Sampler and new Tuner. |
| `DBM-D1` | DrivenByMoss Ableton Push manual, Edit Modes → Device. |
| `DBM-B1` | DrivenByMoss Ableton Push manual, Edit Modes → Browse. |
| `DBM-C1` | DrivenByMoss Device mode chain/layer navigation for devices with slots/layers. |
| `DBM-W?` | DrivenByMoss's conditional Window button. Availability is host/device dependent and must be verified. |

The accepted DrivenByMoss manual baseline is the PDF embedded in the accepted fork at commit `7e3416a1bdddbcbeec4e35e6531652e1618723de`.

## Most important finding

The DrivenByMoss manual does **not** contain a per-native-device interaction catalog.

It documents a generic Push Device mode:

- select a device or parameter bank;
- enable/disable;
- show remote controls;
- toggle expanded/small view;
- enter chains where available;
- pin the device;
- open a plug-in or supported Bitwig pop-out;
- edit eight current remote-control parameters;
- use Shift for fine adjustment;
- reset through Delete + touch;
- browse presets.

That is meaningful controller coverage, but it is not device-specific visual behavior. Therefore every row begins with:

```text
device-specific DrivenByMoss behavior: NONE_DOCUMENTED
verification: MANUAL_BASELINE; SOURCE/FIXTURE_VERIFY
```

A row must not be promoted merely because eight generic parameters can be changed.

## Four separate questions

For every device or workflow, the catalog keeps these questions separate:

| Question | Example |
|---|---|
| Does the Bitwig feature exist? | Sampler has slicing markers and waveform zoom. |
| Can DrivenByMoss currently operate the relevant state? | A remote-control parameter is bound to an encoder. |
| Can Pushwig locate the meaningful visual subject? | The selected Sampler and its active marker are identified. |
| Has Pushwig designed a useful presentation? | Device overview, touched-parameter focus, or full-width waveform. |

The answer to one question does not imply the next.

## Cross-cutting screen/context matrix

This is the first product-level context map. It is intentionally smaller than the device inventory.

| Context | Current DrivenByMoss behavior | Proposed Pushwig behavior | Priority | Current decision |
|---|---|---|---|---|
| Track, mixer, transport, session and performance pages | Existing semantic Push layouts | No change unless a specific superior design is proven | Preserve | **Keep DrivenByMoss** |
| Generic device page, unsupported device | Eight current parameters with names/values/bars | No capture merely because a device is selected | Preserve | **Keep DrivenByMoss** |
| Supported native-device overview | Eight current parameter bindings | Tight native-device surface, bottom-centered; stable encoder legends and contextual values around it | P0/P1 | **Design** |
| One encoder touched | Parameter touch/value semantics | Highlight mapped region; gentle focus while preserving the parameter binding | P0 | **Design with Sampler** |
| Several encoders touched | No multi-parameter visual framing | Frame the union of verified mapped regions plus margin; no fabricated mapping | P1 | **Design after one-control proof** |
| Sampler playback/loop boundary edit | Numeric parameter representation | Full or dominant waveform; emphasize the active marker and useful surrounding interval | P0 | **Design now** |
| Sampler sliced workflow | Generic parameter pages | Waveform-dominant selected-slice/boundary/playback presentation | P0/P1 | **Capability audit required** |
| Browser | Filters on encoders 1–7; result/patch on encoder 8; preview/confirm/cancel | Results-first semantic browser with dynamic filter focus, explicit audition/commit/cancel | P0 | **Design now** |
| Macros, modulators and unknown mappings | Generic parameters | Preserve semantics; never invent a graphical target | Defer | **Keep DrivenByMoss** |
| Unknown plug-ins | Generic parameters; window toggle where available | Optional explicit profile/focus capture later; semantic fallback by default | Defer | **Not initial scope** |

## Initial behavior families

The CSV assigns every device to one provisional behavior family. These are product-design hypotheses, not inheritance classes or implementation modules.

| Family | Rows | Intended use |
|---|---:|---|
| `waveform-boundary` | 2 | Sampler and Convolution-style waveforms, markers, ranges and precision focus. |
| `analyzer` | 7 | Oscilloscope, Spectrum, Tuner and spectral split displays. |
| `graph-control` | 39 | EQ/filter/dynamics/delay/modulation relationships and focused controls. |
| `device-overview` | 11 | Recognizable native device with encoder-linked visual regions. |
| `structure-navigation` | 15 | Containers, Drum Machine, layers, chains and selected-child context. |
| `sequence-note-flow` | 22 | Arpeggiators, step devices and note-processing behavior. |
| `drum-voice` | 31 | Compact synthesized drum voices; initially preserve generic semantics. |
| `semantic-status` | 21 | Routing, hardware, MIDI and utility information better expressed as values/state. |
| `patch-canvas` | 3 | Grid devices; requires a separate patch-navigation model. |

## Initial priority cohort

These are the devices worth examining first. The ranking is about **musical/visual payoff**, not engineering prestige.

| Priority | Device | Family | Why it is early |
|---|---|---|---|
| P0 | Sampler | `waveform-boundary` | First complete native-device experience: overview, parameter focus, markers and sliced workflows. |
| P1 | Oscilloscope | `analyzer` | The visualization is the device's main value. |
| P1 | Spectrum | `analyzer` | Native frequency display is directly useful on Push. |
| P1 | Tuner | `analyzer` | Pitch, cents, frequency and history are compact and inherently visual. |
| P1 | EQ+ | `graph-control` | Clear encoder-to-band and response-graph opportunity. |
| P1 | Filter+ | `graph-control` | Response/waveshaper visual can make parameter editing legible. |
| P1 | Compressor+ | `graph-control` | Gain reduction and transfer behavior can complement parameter values. |
| P1 | Resonator Bank | `graph-control` | Multiple resonant bands benefit from graphical focus. |
| P1 | Freq/Harmonic/Loud/Transient Split | `analyzer` | The visual split is central to understanding the device. |
| P1 | FM-4, Phase-4, Polymer, Polysynth | `device-overview` | Representative synths for testing reusable overview/focus behavior. |
| P1 | Drum Machine | `structure-navigation` | Pad/cell/chain context needs a different presentation from eight generic bars. |
| P1 | Arpeggiator, Note Repeats, Stepwise | `sequence-note-flow` | Pattern and timing state deserve purpose-built presentation. |
| P1 | Convolution | `waveform-boundary` | The impulse visual can provide useful native context. |

The **Browser** is also P0, but it is a screen/workflow rather than a native-device row.

## Priority meanings

| Priority | Meaning |
|---|---|
| `P0` | Immediate product-design target. |
| `P1` | First reusable behavior-family cohort. |
| `P2` | Revisit after its behavior family works on one representative device. |
| `P3` | Preserve generic DrivenByMoss semantics unless a clear payoff appears. |
| `P4` | Legacy/deferred. |

Disposition meanings:

| Value | Meaning |
|---|---|
| `DESIGN_NOW` | Include in the first complete experience. |
| `DESIGN_NEXT` | Strong candidate after the first Sampler/device-page behavior. |
| `FAMILY_LATER` | Do not design separately until a reusable family is proven. |
| `PRESERVE_DBM` | Existing generic semantics are the initial product decision. |
| `DEFER` | Complexity or low payoff makes this a later concern. |

## How the matrix should evolve

A device row should gradually gain verified, versioned facts such as:

- exact Bitwig device mode/view being considered;
- current DrivenByMoss mode and current encoder page;
- current parameter binding identity;
- visual surface and named subregions;
- overview/touch/edit/release presentation;
- multi-touch union behavior;
- source-location method and confidence;
- supported Bitwig versions/UI scales/layouts;
- browser or device-state transitions;
- fallback;
- fixture/test status.

Do not turn one row into a giant prose dossier. Complex device-specific behavior can live in a separate profile/design file referenced from the matrix.

## Immediate follow-up design work

1. Read the Sampler sections in the Bitwig 6.1 Quick Guide and the current Bitwig in-app help.
2. Map the accepted DrivenByMoss Device page and encoder bindings for Sampler on the physical fixture.
3. Separate Sampler tasks: overview, playback boundaries, loop boundaries, sliced selection/boundaries, and mode-specific controls.
4. Design the resting device page and one-encoder touch state before implementing device recognition.
5. Map the Browser's results/filter/preview/commit/cancel flow independently.
6. Select one additional visual family device—likely `EQ+`, `Spectrum`, or `Polymer`—to test whether the behavior library generalizes.

## Important limitations

- The official Bitwig user guide is currently supplemented by the 6.1 Quick Guide while Bitwig revises the full guide.
- Bitwig's in-app Interactive Help is authoritative for many current device parameters but is not yet represented in this repository.
- Manual coverage is not proof that the Bitwig Controller API exposes a state.
- DrivenByMoss manual coverage is not proof of a stable parameter-to-pixel mapping.
- The CSV is a first-pass design catalog, not a compatibility promise.
