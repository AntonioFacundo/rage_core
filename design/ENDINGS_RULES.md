# Endings Rules - "I Live With 2 Dogs"

This document defines the scoring model and ending selection for the sprint.
All values are on a 0-100 scale.

## Metrics
- Work (W): productivity/feature completion for the day.
- Stress (S): accumulated stress (higher is worse).
- Dogs (D): overall dog happiness/settledness (higher is better).

## Per-day updates (suggested)
- W increases with completed tasks, decreases with dropped calls and failed fixes.
- S increases with interruptions, deadline pressure, and mistakes.
- D increases with play/attention, decreases with ignored requests and noise events.

## Sprint length
- Default: 5 days.
- Optional: 3 (short) or 7 (long) days.

## Daily sleep buff/debuff
At end of each day, compute a "Sleep Quality" result that applies to the next day.
This is a temporary modifier; it does not change the final ending directly.

Suggested rules:
- Sleep Buff: if S <= 30 and D >= 60, next day +10 W and -10 S.
- Sleep Debuff: if S >= 70 or D <= 30, next day -10 W and +10 S.
- Neutral: no changes.

Notes:
- Apply the modifier at the start of the next day.
- Clamp W/S/D to 0-100 after applying.

## Sprint totals
Compute daily averages, then a sprint average:
- W_avg = average of daily W
- S_avg = average of daily S
- D_avg = average of daily D

Optional penalty:
- If any single day S >= 95, mark "S_critical".
- If any single day D <= 10, mark "D_critical".
- If any single day W <= 10, mark "W_critical".

## Buckets
Use these buckets when selecting endings:
- W: low (0-39), mid (40-69), high (70-100)
- S: low (0-39), mid (40-69), high (70-100)
- D: low (0-39), mid (40-69), high (70-100)

## Priority rules (override)
1) If S_critical: Ending = "Total Collapse (Fatal)".
2) Else if D_critical: Ending = "Dog Rebellion (System Wrecked)".
3) Else if W_critical: Ending = "Instant Termination".
4) Else continue with bucket matrix.

## Ending selection (bucket matrix)
The narrative is driven by the *worst bucket* plus the strongest positive offset.

Legend:
- W = Work, S = Stress, D = Dogs
- "+" means high, "0" means mid, "-" means low.

1) W- / S+ / D-
   - "Fired + Fatal Collapse"
2) W- / S+ / D0 or D+
   - "Fired + Breakdown"
3) W- / S0 / D-
   - "Fired, Quiet Night"
4) W- / S0 / D+
   - "Fired, Dog Happy Ending"
5) W- / S- / D-
   - "Walk Away: Remote Life Ends"
6) W- / S- / D0 or D+
   - "Fired but at Peace"

7) W0 / S+ / D-
   - "Warning + Breakdown"
8) W0 / S+ / D0 or D+
   - "Barely Survived"
9) W0 / S0 / D-
   - "Mediocre Remote Day"
10) W0 / S0 / D+
   - "Decent Day, Calm Night"
11) W0 / S- / D-
   - "Stable Job, Cold House"
12) W0 / S- / D0 or D+
   - "Stable Remote Life"

13) W+ / S+ / D-
   - "Promotion + Health Crash"
14) W+ / S+ / D0 or D+
   - "Promotion + Hospital Visit"
15) W+ / S0 / D-
   - "Promotion, Home Tense"
16) W+ / S0 / D+
   - "Golden Day (Remote Deluxe)"
17) W+ / S- / D-
   - "Promotion, Lonely Win"
18) W+ / S- / D0 or D+
   - "Promotion + Great Night"

## Flavor mapping for extremes
- "Total Collapse (Fatal)": Screen blackout; dogs whine; game over.
- "Golden Day (Remote Deluxe)": Gold toys, gold keyboard, gold dog bed.
- "Dog Rebellion": Camera shakes; desk flips; sprint fails.

## Final scenes timing
- Ending scenes trigger on the final sprint day.
- Ending scenes also trigger immediately if the run is lost early.
- Non-final days should show a short summary, not a full ending scene.

## Notes
- Replace or tune thresholds as the playtest data evolves.
- If desired, add a "perfect day" bonus: W >= 90, S <= 20, D >= 90.
