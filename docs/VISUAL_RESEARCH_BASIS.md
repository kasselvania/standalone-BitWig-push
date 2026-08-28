# Visual Portability Research Basis

## Purpose

This document records the public platform facts that make adaptive Bitwig-to-Push visuals plausible and separates them from project hypotheses that still require implementation and testing.

## Confirmed Bitwig UI capabilities

### Structured application layout

Bitwig documents a window body with defined central, secondary, access, and inspector panel areas. Which panels are available and where they appear depends on the active view and display profile.

References:

- <https://www.bitwig.com/userguide/latest/the_window_body/>
- <https://www.bitwig.com/userguide/latest/the_window_footer/>
- <https://www.bitwig.com/userguide/latest/anatomy_of_the_bitwig_studio_window/>

### Display profiles and GUI scaling

Bitwig provides display profiles for different screen arrangements, including profiles that create more than one application window. It also exposes GUI scaling controls.

References:

- <https://www.bitwig.com/userguide/latest/a_musical_swiss_army_knife/>
- <https://www.bitwig.com/userguide/latest/anatomy_of_the_bitwig_studio_window/>

This confirms that a universal visual resolver cannot assume one application window, one panel arrangement, or one UI scale.

### Expanded Device Views and floating windows

Bitwig documents Expanded Device Views for native devices including Sampler and several synths, effects, analyzers, and Grid devices. An Expanded Device View can be undocked into a separate floating window.

Reference:

- <https://www.bitwig.com/userguide/latest/introduction_to_devices/>

This makes a floating native-device view a strong first source class: it can be captured by window identity instead of by a physical desktop rectangle.

## Confirmed controller/integration observations

Current DrivenByMoss source contains Bitwig application abstractions that observe/set panel layout and toggle device, mixer, inspector, browser, and fullscreen state:

- <https://github.com/git-moss/DrivenByMoss/blob/master/src/main/java/de/mossgrabers/bitwig/framework/daw/ApplicationImpl.java>

Its Bitwig device abstraction observes device expansion and plug-in-window state and can toggle those states:

- <https://github.com/git-moss/DrivenByMoss/blob/master/src/main/java/de/mossgrabers/bitwig/framework/daw/data/SpecificDeviceImpl.java>

These observations do not prove that every source can be opened or identified perfectly through the controller API. They do establish useful semantic coordination points for a source resolver.

## Confirmed operating-system capture families

### Linux Wayland / sandboxed applications

The XDG ScreenCast portal supports monitor, window, and virtual-monitor sources and returns PipeWire streams. It also defines persistent-session restore tokens.

- <https://flatpak.github.io/xdg-desktop-portal/docs/doc-org.freedesktop.portal.ScreenCast.html>

### Windows

`Windows.Graphics.Capture` supports acquiring frames from an application window or display.

- <https://learn.microsoft.com/en-us/windows/apps/develop/media-authoring-processing/screen-capture>

### macOS

ScreenCaptureKit can enumerate captureable windows and create a filter for a specific desktop-independent window.

- <https://developer.apple.com/documentation/screencapturekit/scshareablecontent/windows>
- <https://developer.apple.com/documentation/screencapturekit/sccontentfilter/init(desktopindependentwindow:)>

These APIs support the architectural decision to keep operating-system window/capture handles behind backend adapters while exposing a common frame contract to the resolver/compositor.

## Project hypotheses requiring proof

The following are not yet established facts:

- that Bitwig floating Expanded Device View windows have sufficiently stable titles/classes/metadata across versions and operating systems;
- that all useful third-party editor windows can be associated reliably with the selected Bitwig device;
- that embedded Bitwig panels can be located robustly from semantic state, normalized geometry, and visual anchors across the intended display-profile/UI-scale matrix;
- that Wayland portal persistence provides an acceptable appliance/user experience on every target compositor;
- that one visual-adapter representation can be shared unchanged across all operating systems;
- that automated anchor detection will outperform bounded user calibration for every source class.

These questions are the subject of Track V implementation slices, not assumptions to write around.

## Leading proof order

1. trace and own the Push framebuffer path;
2. discover/capture a floating Bitwig Expanded Device View;
3. discover/capture one ordinary plug-in editor;
4. define the public source/adapter contracts;
5. solve one embedded native-device panel adaptively;
6. test across layouts, scales, monitors, and capture backends;
7. add bounded calibration and additional platform backends.
