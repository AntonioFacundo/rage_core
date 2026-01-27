# Game Design Document - "I Live With 2 Dogs"

## 1) High Concept
A remote game developer tries to finish a sprint while two dogs constantly interrupt. The player balances productivity, stress, and dog happiness across a short sprint to reach a variety of endings.

## 2) Core Pillars
- **Tension vs. Care**: Productivity competes with dog attention.
- **Short-term choices**: Each day is a bite-sized management loop.
- **Readable consequences**: Metrics clearly shift based on actions.
- **Comedic realism**: Everyday chaos, playful exaggeration.

## 3) Target Experience
Light management with comedic stress, rapid day loops, and multiple endings that encourage replay.

## 4) Gameplay Loop
1) Start day with current stats and sleep buff/debuff.
2) Work on tasks while handling dog interruptions.
3) React to random events (calls, barking, monitor disconnect).
4) End day, compute sleep quality for next day.
5) Final day or loss triggers ending scene.

## 5) Player Metrics (0-100)
- **Work (W)**: Productivity and task completion.
- **Stress (S)**: Accumulated pressure; high S causes penalties.
- **Dogs (D)**: Dog happiness/settledness.

## 6) Day Structure
- **Morning**: Lower interruptions, planning window.
- **Midday**: Calls appear, dog events spike.
- **Evening**: Deadline pressure increases; higher stress decay risk.

## 7) Core Actions
- **Code Task**: Raises W, raises S slightly.
- **Fix Bug**: Raises W, raises S more.
- **Play Fetch**: Raises D, small W decrease, risk of monitor disconnect.
- **Show Door**: Reduces barking event, small time cost.
- **Short Break**: Reduces S slightly, no W gain.
- **Call**: Time-limited; failure hurts W and S.

## 7.1) Dev Task Catalog (Work Activities)
These are the core work activities during the day.
- **Implement Feature**: Medium duration, solid W gain.
- **Fix Bug**: Short/medium duration, medium W gain, higher S.
- **Refactor / Cleanup**: Longer duration, small W gain, lowers future S spikes.
- **Review PR**: Short duration, small W gain, lowers future bug events.
- **Write Tests**: Medium duration, small W gain, reduces bug event chance.
- **Documentation**: Medium duration, small W gain, reduces call penalties.
- **Build / Deploy**: Short duration, moderate W gain, risk of failure event.

## 7.4) Task Overload Model
The game should present many small tasks at once. The player must pick which to accept and which to ignore.
Ignoring tasks always has a cost that affects one of the three metrics:
- Ignore a dev task: lose W (missed progress).
- Ignore a dog request: lose D (happiness drops).
- Ignore a work interruption (call/ping/intern): gain S or increase future bug risk.

This creates constant tradeoffs between W, S, and D.

## 7.5) Suggested Numbers (Baseline)
These are starting values to tune.

Task durations (seconds):
- Micro task: 15-25s
- Small task: 25-45s
- Medium task: 45-70s

Task effects:
- Implement Feature (small/medium): +8 W, +4 S
- Fix Bug (micro/small): +6 W, +6 S
- Refactor / Cleanup (medium): +4 W, -3 future S spikes
- Review PR (micro): +3 W, -2 bug chance
- Write Tests (small): +4 W, -4 bug chance
- Documentation (small): +3 W, -2 call penalty
- Build / Deploy (micro): +5 W, +2 S, 20% failure chance

Ignore penalties:
- Ignore dev task: -5 W
- Ignore call/ping/intern: +5 S (intern ignore also +10% next-day bug chance)
- Ignore dog request: -8 D

Dog actions:
- Play Fetch: +10 D, -2 W, 25% monitor disconnect
- Show Door: +6 D, -2 W, 15% dog escapes (time loss)
- Quick Pet: +3 D, no W change, short duration

Event consequences:
- Monitor disconnect: lose 10-20s, +4 S
- Dog escapes: lose 20-40s, +6 S, -3 W

## 7.6) Daily Task Scheduler
- Start each day with 3-5 tasks available.
- Every 30-45s, add 1 new task until a max of 7 active tasks.
- Hard cap: 7 active tasks (new tasks queue up as pressure).
- If active tasks exceed 5 for more than 30s: +2 S every 15s.

## 7.2) Stress Triggers (Work Context)
These are the main stress sources while working.
- **Interruptions**: Dog events, calls, notifications.
- **Deadline Pressure**: Increases as day progresses.
- **Context Switching**: Jumping between tasks too often.
- **Failure Events**: Build fails, call drops, monitor disconnect.
- **Unresolved Barking**: Dog A or B left unattended too long.

## 7.3) Random Work Events
These occur while trying to work.
- **Surprise Call**: Must answer/decline; affects W and S.
- **Urgent Bug Report**: Forces a quick fix or delay penalty.
- **Build Failure**: Requires a short fix minigame.
- **Stakeholder Ping**: Adds stress if ignored; optional quick response.
- **Task Scope Creep**: Adds extra steps to current feature.
- **Intern Question**: Simple request that interrupts focus; low W impact, small S increase if ignored.
  - If ignored repeatedly: adds higher bug chance next day or a final-day error event.

## 8) Random Events
- **Monitor Disconnect**: Triggered by fetch; causes a recovery minigame.
- **Barking at Nothing**: Requires a quick response.
- **Surprise Call**: Must decide to answer, delay, or ignore.
- **Slack Ping**: Low impact; piles up stress if ignored.

## 9) Dog Behaviors
- **Dog A (ball-focused)**: Wants fetch regularly; if ignored, D drops fast.
- **Dog B (barking)**: Random barking events; must be calmed.
- **Angry Barking**: If Dog A is ignored too long, enters a sustained bark mode.

## 10) Coffee & Melatonin
- **Coffee (Boost)**:
  - Immediate: +W, short-term S reduction.
  - Tradeoff: Later S spike or worse sleep quality.
- **Melatonin (Sleep Aid)**:
  - Improves next-day sleep buff chance.
  - Tradeoff: Lower early-day W or slower reaction time.

## 11) Sleep Buff/Debuff
End-of-day sleep quality modifies next day:
- Good sleep: +W and -S next day.
- Poor sleep: -W and +S next day.

## 12) Win/Loss Conditions
- **Loss**: S reaches critical, or W collapses to zero on a key day.
- **Win**: Finish the sprint and trigger an ending.

## 13) Endings
Based on combined W/S/D averages and critical events. See:
`design/ENDINGS_RULES.md`

## 14) Art & Tone
- Cozy home office, cluttered desk, warm palette.
- Subtle animation emphasis on dog antics.
- Humor in UI: faux calendar, tiny dev notes.

## 14.1) Camera & Interaction Style (FNAF-like)
- **Fixed perspective**: The developer never moves; only cursor interactions.
- **Hotspot interactions**: Clickable desk objects (PC, ball, door, coffee, melatonin).
- **Door check**: A quick “peek” view outside to calm barking.
- **Risk tradeoff**: Opening the door can trigger a dog escape event.
- **UI-driven focus**: Most feedback comes via HUD and popups, not movement.

## 14.2) Hotspot Layout (Suggested)
Screen is divided into a static desk scene with clickable zones.

Primary hotspots:
- **PC/Monitor** (center): Work tasks, calls, notifications.
- **Ball/Throw zone** (right side): Play fetch action.
- **Door** (left side): Open/peek to calm barking.
- **Cable/Power strip** (lower right): Recover from disconnect.
- **Coffee mug** (right/top): Coffee boost.
- **Nightstand/Drawer** (left/top): Melatonin for sleep aid.

Secondary hotspots (optional):
- **Phone** (near monitor): Accept/decline calls.
- **Notes/Planner** (left of monitor): View task queue.
- **Trash bin** (bottom corner): Quick “clear desk” stress relief.

## 14.3) Wireframe (Text, 0-100% coords)
Coordinate system: (0,0) = top-left, (100,100) = bottom-right.

Hotspot rectangles (x1,y1,x2,y2):
- **PC/Monitor**: 35,25,70,60
- **Phone**: 70,30,82,45
- **Ball/Throw zone**: 78,55,98,85
- **Door**: 0,30,12,85
- **Cable/Power strip**: 70,85,95,98
- **Coffee mug**: 60,15,72,28
- **Nightstand/Drawer**: 12,10,28,25
- **Notes/Planner**: 28,30,35,45
- **Trash bin**: 0,85,12,100

## 14.4) Hotspot Feedback (UI/UX)
- **Cursor change**: Highlight/hand icon when hovering a hotspot.
- **Tooltip**: Short label + cost/benefit (e.g., "+D, risk disconnect").
- **Hover glow**: Subtle outline to confirm target area.
- **Click response**: Sound cue + small animation (button press, shake, pulse).
- **Cooldown indicator**: Tiny ring or timer near the hotspot if on cooldown.

## 15) Audio
- Soft ambient home noise.
- Dog barks and fetch SFX.
- Notification sounds for calls and pings.

## 16) UI/UX
- Persistent meters for W/S/D.
- Minimal text prompts, large action buttons.
- End-of-day summary panel (not full ending unless final day).

## 17) Progression
- Sprint length selectable (3/5/7).
- Unlock small perks (better toys, stable monitor, training).

## 18) MVP Scope
- One sprint length (5 days).
- Two dog behaviors.
- Calls, barking, fetch, monitor disconnect.
- 6-10 endings.

## 19) Risks & Open Questions
- Balancing stress penalties without feeling unfair.
- Ensuring dogs feel like characters, not pure timers.
- How comedic to make the “fatal collapse” ending.

## 20) Next Steps
- Build a paper prototype with daily loops.
- Implement basic event scheduler.
- Playtest for pacing and fairness.

## 21) Daily Task Briefing
At the start of each day, present a list of tasks with:
- **Estimated time** (duration range).
- **Difficulty** (translates into stress).
- **Priority** (affects scoring and rewards).

## 22) Work Characters & Calls
All calls can be interrupted by dog events. If interrupted, the caller’s response is negative and may change rewards.

- **PM/SM (Project Manager / Scrum Master)**:
  - Calls to update priorities.
  - If missed, the player does not learn which tasks changed value.
  - Risk: you might complete a difficult task that no longer grants points.
  - If dogs interrupt the call (noise), PM/SM gets annoyed.

- **Intern**:
  - Asks easy questions that take a small time cost.
  - Takes a noticeable time cost to answer (longer than a quick ping).
  - If ignored repeatedly, next day starts with extra tasks.

- **Boss**:
  - Calls for high-priority requests.
  - Missing the call increases stress and reduces W for the day.

- **Coworker**:
  - Asks for help; costs time but grants a **Joker token**.
  - Joker can be used later to reduce the cost of a task or skip a minor penalty.

## 23) Interruption Rule
Any ongoing action (task, call, or event) can be interrupted by:
- Dog barking
- Ball request
- Door check
Interruption either pauses or cancels the action, with stress penalties.

Calls can also be disrupted by negative dog outcomes:
- **Monitor disconnect** during a call cancels it.
- **Dog escape** during a call cancels it.
