# Endless: current rules

Endless starts a fresh survival run in Meadow, separate from the finite Adventure stages. Collect food to increase score, avoid threats, and keep going until all hearts are gone. Easy starts with five hearts, Normal with four, and Hard with three. The local personal best is recorded at the end of a run. Gems and discoveries use the shared wallet and field guide.

World changes are driven by score, not by elapsed time or distance:

| Score | World |
| --- | --- |
| 0 | Meadow |
| 1,000 | Nightfall |
| 2,000 | Desert |
| 3,000 | Tundra |
| 4,000 | Jungle |
| 5,000 | Cave |
| 7,000 | Deep Sea |
| 8,000 | Volcano |
| 9,000 | Sky Kingdom |
| 10,000 | Swamp |
| 11,000 | Garden |
| 12,000 | Ancient Ruins |
| 13,000 | Mushroom Forest |
| 14,000 | Crystal Caverns |
| 15,000 | Space |
| 18,000 | Mars |

Boss checks occur at 6,000 in Cave, 11,600 in Garden, and 17,000 in Space. Each can be defeated once per run. Scrolling accelerates from 160 to a maximum of 300 scene points per second as distance increases; boss arenas pause ordinary scrolling.

## Current limits

Mars continues indefinitely after 18,000; the world sequence does not loop. The score record is local and currently shared across difficulty choices. The current menu starts a fresh run; older checkpoint storage still exists in the game code but is not exposed as an Endless resume button. Adventure progress and its stars remain separate.

## Candidate improvements, not implemented in the art pass

A clear Endless introduction with the selected difficulty and personal best; separate records per difficulty; distance and next-world progress in the HUD; and an explicit decision between looping worlds or remixed encounters after Mars. These should be a dedicated gameplay pass with balance testing.
