# Approved Sampler presentation

September 10, 2026: the maintainer chose **A — four permanent remote readouts on each side of the device image**. Top device-action labels/states remain in their eight physical columns; bottom device/page navigation remains. Values stay visible without touch. Raw encoder touch adds emphasis and does not move the image.

The throwaway A/B simulator has served its purpose and is removed. Its exact review source remains in [Git history at ce72420](https://github.com/kasselvania/standalone-BitWig-push/tree/ce72420e365615912c6e013810a48f3f83ef4cf6/visuals/sampler/presentation-prototype). Neither the generated context IDs nor the simulated marker associations became production authority.

The [implementation contract](../../../docs/design/sampler-context-lens.md) now owns the decision. DrivenByMoss renders actual button labels, navigation, remote aliases/formatted values and touch emphasis. FFmpeg supplies only the center `(238,25,484,114)`. No unverified image markers are rendered.

Design approval is not physical acceptance. Native device association, current image/control correspondence, text readability on Push, continuous tracking and performance must be qualified by the real test.
