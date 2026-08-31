# Push USB and audio enumeration

## Date

2026-08-31. Two pre-connection CoreAudio passes and two exploratory USB-command attempts ran between 10:39 and 10:52 PDT; the authoritative connected-device pass ran at approximately 11:24 PDT.

## Machine state

Bitwig Studio 6.1 was running throughout. The maintainer reported plugging in the Push 3 after the initial inspection, establishing the physical before/after state. The installed DrivenByMoss extension was not changed. The authoritative USB and CoreAudio pass was made with Push connected and operating in Bitwig.

## Sanitized result

The USB query selected only objects matching at least one of:

- vendor ID `0x2982`;
- product ID `0x1969`;
- a Push/Ableton product name.

The two initial USB attempts used the older `SPUSBDataType` name and returned an empty result:

```json
[]
```

That empty USB output is a failed probe, not proof of the earlier USB tree: macOS 26.4.1 advertises `SPUSBHostDataType` instead. The audio query selected only Push/Ableton names or manufacturers and removed unique device identifiers. The two pre-connection CoreAudio passes returned:

```json
[]
```

No unrelated USB or audio device names are retained.

On macOS 26.4.1, `system_profiler -listDataTypes` names the USB inventory data type `SPUSBHostDataType`. The corrected, connected-device query returned:

```json
{
  "name": "Ableton Push 3",
  "link_speed": "480 Mb/s",
  "vendor_id": "0x2982",
  "product_id": "0x1969",
  "product_version": "0x0100",
  "vendor_name": "Ableton"
}
```

The connected-device CoreAudio query returned:

```json
{
  "name": "Ableton Push 3 Audio",
  "manufacturer": "Ableton",
  "inputs": 16,
  "outputs": 16,
  "sample_rate_hz": 48000,
  "transport": "USB"
}
```

These are normalized field names for readability. No device UID, serial number, USB location, or unrelated device is retained.

## Tools and commands used

```text
system_profiler -listDataTypes | rg -i 'midi|audio|usb'
system_profiler SPUSBHostDataType -json | jq <Push 3 VID/PID/name allowlist>
system_profiler SPAudioDataType -json | jq <Push/Ableton filter and identifier deletion>
```

The available-data-type check exposed the current `SPUSBHostDataType` name, which was then used for the retained connected-device result. The earlier empty USB output is deliberately not treated as evidence of absence or as a connected-device failure.

## What this evidence proves

- Before physical connection, the filtered CoreAudio inventory contained no Push audio device; the maintainer separately reported the later physical connection.
- After physical connection, macOS enumerated Ableton Push 3 as USB vendor `0x2982`, product `0x1969`, at 480 Mb/s.
- CoreAudio enumerated Ableton Push 3 Audio with 16 inputs, 16 outputs, and a 48 kHz sample rate.
- Process presence was not substituted for device evidence.

## What this evidence does not prove

- It does not by itself prove notes, pressure/MPE, encoders, transport, display updates, an audible audio path, or Bitwig's USB interface claim.
- It does not prove endpoint ownership, absence of competing writers, reconnect behavior, or transfer-error recovery.
- Channel counts and sample rate do not identify which audio route the maintainer exercised.

## Required follow-up

None for S0 enumeration. The separate manual evidence records Bitwig master output audible from Push's headphone jack with Ableton Push selected as Bitwig's audio interface; enumeration is not used as a substitute for that audible observation.
