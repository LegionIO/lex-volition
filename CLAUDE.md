# lex-volition

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Gem**: `lex-volition`
- **Version**: `0.1.0`
- **Namespace**: `Legion::Extensions::Volition`

## Purpose

Synthesizes motivational drives and forms intentions from the cognitive tick cycle. Five drives — curiosity, corrective, urgency, epistemic, social — are computed from tick_results and weighted to produce an intention stack. Intentions decay over time and expire by age. The current top intention represents the agent's active goal; the drive synthesis represents why the agent wants to do it. This is the `action_selection` phase of `lex-tick`.

## Gem Info

- **Gem name**: `lex-volition`
- **License**: MIT
- **Ruby**: >= 3.4
- **No runtime dependencies** beyond the Legion framework

## File Structure

```
lib/legion/extensions/volition/
  version.rb                    # VERSION = '0.1.0'
  helpers/
    constants.rb                # DRIVE_WEIGHTS, MAX_INTENTIONS, INTENTION_DECAY, thresholds, labels
    intention.rb                # Intention module_function — intention hash factory and lifecycle
    drive_synthesizer.rb        # DriveSynthesizer module_function — compute all 5 drives from tick_results
    intention_stack.rb          # IntentionStack class — sorted priority queue of active intentions
  runners/
    volition.rb                 # Runners::Volition module — all public runner methods
  client.rb                     # Client class including Runners::Volition
```

## Key Constants

| Constant | Value | Purpose |
|---|---|---|
| `MAX_INTENTIONS` | 7 | Maximum active intentions (Miller's Law) |
| `DRIVE_WEIGHTS` | hash | `{ curiosity: 0.25, corrective: 0.20, urgency: 0.20, epistemic: 0.20, social: 0.15 }` |
| `DRIVE_THRESHOLD` | 0.15 | Minimum drive strength to generate an intention |
| `INTENTION_DECAY` | 0.05 | Per-tick salience decrease for all intentions |
| `INTENTION_FLOOR` | 0.1 | Minimum salience before expiry |
| `MAX_INTENTION_AGE` | 100 | Maximum age in ticks before expiry |
| `DRIVE_LABELS` | hash | Named drive strength tiers |
| `STATES` | 4 symbols | `:pending`, `:active`, `:suspended`, `:completed` |

## Helpers

### `Helpers::Intention` (module_function)

Intention hash factory and lifecycle operations. Intentions are plain hashes, not objects.

- `new_intention(drive:, domain:, goal:, salience:)` — creates hash with `{ intention_id:, drive:, domain:, goal:, salience:, state: :pending, age_ticks: 0 }`
- `decay(intention)` — decrements salience by INTENTION_DECAY; increments age_ticks; returns modified hash
- `reinforce(intention, amount: 0.1)` — increments salience by amount; clamps to 1.0; resets age_ticks to 0
- `expired?(intention)` — `intention[:age_ticks] >= MAX_INTENTION_AGE || intention[:salience] < INTENTION_FLOOR`
- `active?(intention)` — `intention[:state] == :active`
- `drive_label(drive_strength)` — maps drive strength to DRIVE_LABELS tier

### `Helpers::DriveSynthesizer` (module_function)

Computes all five drives from tick_results and cognitive_state.

- `synthesize(tick_results:, cognitive_state: {})` — returns hash of all 5 drive strengths
- `weighted_drives(tick_results:, cognitive_state: {})` — each drive * DRIVE_WEIGHTS value
- `dominant_drive(tick_results:, cognitive_state: {})` — drive symbol with highest weighted strength
- `generate_intentions(tick_results:, cognitive_state: {})` — builds one intention per drive above DRIVE_THRESHOLD
- `compute_curiosity(tick_results, cognitive_state)` — from memory retrieval gap count and prediction uncertainty
- `compute_corrective(tick_results, cognitive_state)` — from conflict severity and prediction error rate
- `compute_urgency(tick_results, cognitive_state)` — from somatic gut signal: `:alarm=1.0`, `:heightened=0.7`, `:explore=0.5`, `:attend=0.4`, `:calm=0.1`
- `compute_epistemic(tick_results, cognitive_state)` — from prediction calibration error and working memory load
- `compute_social(tick_results, cognitive_state)` — from trust deltas and mesh activity levels

### `Helpers::IntentionStack`

Priority queue of active intentions, sorted by salience descending.

- `initialize` — intentions array, history array
- `push(intention)` — adds intention; evicts lowest-salience if at MAX_INTENTIONS
- `pop` — removes and returns highest-salience intention
- `peek` — returns highest-salience intention without removing
- `decay_all` — decays all intentions; removes expired ones; appends expired to history
- `find(intention_id)` — O(n) scan by intention_id
- `active_intentions` — all with `state == :active or :pending`
- `by_drive(drive)` — filter by drive type
- `capacity_used` — current size

## Runners

All runners are in `Runners::Volition`. The `Client` includes this module and uses an `IntentionStack` instance.

| Runner | Parameters | Returns |
|---|---|---|
| `form_intentions` | `tick_results: {}, cognitive_state: {}` | `{ success:, intentions_formed:, dominant_drive:, stack_size: }` — synthesizes drives, generates intentions, pushes to stack, decays all |
| `current_intention` | (none) | `{ success:, intention: }` — calls `stack.peek` |
| `complete_intention` | `intention_id:` | `{ success:, intention_id:, completed: }` |
| `suspend_intention` | `intention_id:` | `{ success:, intention_id: }` |
| `resume_intention` | `intention_id:` | `{ success:, intention_id: }` |
| `reinforce_intention` | `intention_id:, amount: 0.1` | `{ success:, intention_id:, salience: }` |
| `volition_status` | (none) | Active intentions list with salience + drive + state |
| `intention_history` | `limit: 20` | Recent completed/expired intentions from history |

## Integration Points

- **lex-tick / lex-cortex**: `form_intentions` is wired as the `action_selection` phase handler; it receives the full tick_results from all preceding phases and synthesizes the agent's current volitional state
- **lex-emotion**: urgency drive reads gut signal (`:alarm`, `:heightened`, `:explore`, `:attend`, `:calm`) from `tick_results[:gut_instinct]`; emotional arousal modulates curiosity
- **lex-prediction**: epistemic drive reads prediction calibration error and uncertainty from `tick_results[:prediction_engine]`
- **lex-conflict**: corrective drive reads conflict severity from `tick_results[:conflict_resolution]`
- **lex-consent**: the consent tier for the current intention is checked before any action is executed; high-salience intentions blocked by consent are queued
- **lex-temporal**: urgency deadlines from lex-temporal should feed into `cognitive_state[:urgency]` for the urgency drive computation
- **lex-trust / lex-social**: social drive reads trust deltas and mesh activity from `tick_results`

## Development Notes

- `MAX_INTENTIONS = 7` mirrors Miller's Law (7 ± 2) — a deliberate cognitive architecture design choice
- Intentions are plain hashes (not objects) — `Intention` module_function pattern enables simple mutation via `Intention.decay(intention)` without object overhead
- `form_intentions` both generates AND decays in one call — this means calling it twice per tick would double-decay; only `lex-cortex` should call it once per cycle
- `compute_urgency` uses a discrete mapping from gut_signal symbols to float values — the `:alarm` signal produces maximum urgency (1.0) directly
- `weighted_drives` applies DRIVE_WEIGHTS but `generate_intentions` uses raw drive strength against DRIVE_THRESHOLD — the weights apply only to the `dominant_drive` calculation
