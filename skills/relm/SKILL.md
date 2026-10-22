---
name: relm
description: "Load for any Figma → code work (a Figma URL or node id, \"implement this screen\"), for Flutter or web."
---

# Relm: paint it exactly

1. bartz first: the design system and the frames, returned as a spec.
2. Map before calling: keep a node → component table in the repo
   (e.g. `docs/FIGMA-MAP.md`); a mapped node costs zero Figma calls.
3. Budget: one design-context call per COMPONENT, never per screen;
   variables for tokens; export every icon instead of drawing it.
4. Conversion traps: Figma line-height px is a multiplier in Flutter
   (`height`); a 360-wide frame is a constraint, not a fixed width; only
   bundled font weights exist; auto-layout gaps become `spacing` / `gap`.
5. zidane builds; compare against a screenshot of the frame at the end.
6. A refused or rate-limited call: stop and report; never draw from a
   screenshot.
