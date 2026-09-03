# Reference manuals

This directory pins the two manuals used by Pushwig's device/interaction design work:

1. the official **Bitwig Studio User Guide**, supplemented by the official Bitwig Studio 6.1 Quick Guide;
2. the **DrivenByMoss Manual** from the exact accepted fork baseline.

Run:

```bash
./fetch-manuals.sh
```

The PDFs are downloaded into `local/`, and `local/SHA256SUMS` is generated. That directory is intentionally ignored by Git.

## Why the PDFs are not committed here

The Bitwig guide is a large copyrighted publication from Bitwig GmbH. Pushwig should not republish it inside a public Git repository without redistribution permission.

The DrivenByMoss manual is already retained in the accepted DrivenByMoss fork and its documentation source is LGPL-3.0. The central Pushwig repository pins and fetches that exact accepted copy instead of duplicating a large binary that can silently drift from the fork.

This gives contributors one stable local manual directory while keeping source custody and licensing clear.

## Pinned sources

### Bitwig Studio User Guide

Official PDF:

- shortcut: [`Bitwig-Studio-User-Guide.url`](Bitwig-Studio-User-Guide.url)
- official web guide: <https://www.bitwig.com/userguide/latest/>
- pinned PDF URL used by the fetcher: <https://www.bitwig.com/media/bitwig_userguide/pdf/Bitwig_Studio_User_Guide_English_XfuP7Nz.pdf>
- official Device Descriptions index: <https://www.bitwig.com/userguide/latest/device_descriptions/>
- retrieved for this catalog: 2026-09-02

Bitwig's support material says the full guide is being revised for Bitwig Studio 6.1. Therefore the native-device matrix does not treat the full PDF as the sole 6.1 authority.

### Bitwig Studio 6.1 Quick Guide

Official PDF supplement:

- shortcut: [`Bitwig-Studio-6.1-Quick-Guide.url`](Bitwig-Studio-6.1-Quick-Guide.url)
- official PDF: <https://downloads.bitwig.com/6.1/Release-Notes-6.1.pdf>
- retrieved for this catalog: 2026-09-02

This supplement is required for the redesigned Sampler, sliced workflows, and the new Tuner device.

### DrivenByMoss Manual

Exact accepted Pushwig baseline:

- shortcut: [`DrivenByMoss-Manual.url`](DrivenByMoss-Manual.url)
- repository: `kasselvania/DrivenByMoss`
- accepted integration commit: `7e3416a1bdddbcbeec4e35e6531652e1618723de`
- accepted PDF path: `src/main/resources/Documentation/DrivenByMoss-Manual.pdf`
- Git blob: `53dfd80d73b57faf99f3a33c3c594e38f36ba692`
- size: `1,909,123` bytes
- relevant source chapter: <https://github.com/git-moss/DrivenByMoss-Documentation/blob/master/Ableton/Ableton-Push.md>
- documentation license: LGPL-3.0

The matrix primarily references the Ableton Push chapter's **Device** and **Browse** edit modes. The accepted source is consulted where the manual is generic or a behavior needs verification.

## Updating the references

When Bitwig or DrivenByMoss changes:

1. update the URLs/accepted commit here;
2. rerun `fetch-manuals.sh`;
3. record the generated local SHA-256 values in the reviewing PR or issue;
4. update the device matrix only where the documentation or verified behavior changed.

Do not commit the downloaded PDFs or `local/SHA256SUMS`.
