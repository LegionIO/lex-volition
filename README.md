# lex-volition

Drive synthesis and intention formation for LegionIO cognitive agents. Computes five motivational drives from the cognitive tick cycle and produces a prioritized intention stack.

## What It Does

`lex-volition` is the `action_selection` phase of the cognitive cycle. Each tick, it reads the full output of preceding phases and synthesizes five motivational drives. Drives above the threshold generate intentions, which are pushed onto a salience-sorted stack (max 7, per Miller's Law). Intentions decay each tick and expire by age.

- **Drives**: curiosity, corrective, urgency, epistemic, social
- **Drive weights**: curiosity 0.25, corrective 0.20, urgency 0.20, epistemic 0.20, social 0.15
- **Urgency source**: gut signal from lex-emotion (`:alarm`=1.0, `:heightened`=0.7, `:explore`=0.5, `:attend`=0.4, `:calm`=0.1)
- **Intention decay**: -0.05 salience per tick; expire at floor (0.1) or max age (100 ticks)
- **Stack capacity**: 7 intentions max; lowest salience evicted on overflow

## Usage

```ruby
require 'legion/extensions/volition'

client = Legion::Extensions::Volition::Client.new

# Form intentions from tick results (called each cognitive cycle)
result = client.form_intentions(
  tick_results: {
    gut_instinct: { signal: :heightened },
    prediction_engine: { calibration_error: 0.4, uncertainty: 0.6 },
    conflict_resolution: { severity: 0.3 }
  }
)
# => { intentions_formed: 3, dominant_drive: :epistemic, stack_size: 3 }

# Check current top intention
client.current_intention
# => { intention: { drive: :epistemic, domain: :prediction, goal: '...', salience: 0.8, state: :pending } }

# Reinforce an intention (keep it salient)
client.reinforce_intention(intention_id: 'int_1', amount: 0.2)

# Complete an intention
client.complete_intention(intention_id: 'int_1')

# Suspend/resume
client.suspend_intention(intention_id: 'int_2')
client.resume_intention(intention_id: 'int_2')

# Current volition state
client.volition_status
# => { intentions: [{ drive:, goal:, salience:, state:, age_ticks: }, ...] }

# Recent history
client.intention_history(limit: 20)
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
