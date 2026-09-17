# Ladybug Run art direction

Use a friendly illustrated garden style with clear silhouettes and a consistent light source from the upper left. The ladybug stays the strongest red shape in the scene. Creature outlines and expressive eyes must survive at gameplay size; detail that only reads in a large preview is secondary.

## Build 5 pass

- Shared shaded-ellipse paint for the ladybug, aphids, fruit flies, and 17 body shapes in the later-world creature generators. Preserve each creature's original bounds, pose, palette, and collision behavior.
- A cream collar and small smile on the living ladybug; the existing blink and defeated poses retain their distinct expressions. Equipped colors still drive the shell shading.
- Single-piece shaded gameplay clouds rather than translucent circles layered over each other.
- Scalloped deciduous canopies with curved trunks and branches, broad jungle fronds, hanging swamp foliage, snow-capped mountains, and spotted mushroom caps.
- Grass edges, subtle grain, sand ripples, and ground color depth on flat terrain. Cave terrain and the open Space arena retain their existing geometry.
- A simulator-only gallery displays the real generated character textures at review size. It is excluded from Release builds.

## Keep the action readable

Scenery sits behind gameplay. Decorative vegetation must not look like food or a power-up. Keep the upper HUD clear, avoid detailed patterns behind small threats, and preserve the difference between friendly rounded food and hostile angular creatures. Backdrop artwork is flattened into a small number of scrolling textures; do not replace it with hundreds of per-frame nodes.

## Next art opportunities

More distinctive attack anticipation poses for the larger enemies; a dedicated flower and shelter set; matching close-up art for discovered field-guide entries; and a purposeful foreground composition for each boss arena. Review these against actual iPhone footage before adding more visual density.
