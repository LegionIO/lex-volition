# lex-volition

Intention formation and drive synthesis for the LegionIO brain-modeled cognitive architecture.

## What It Does

Gives the agent will. Synthesizes five cognitive drives (curiosity, corrective, urgency, epistemic, social) from other extensions into a ranked intention stack. The agent knows what it wants to do and why.

```ruby
client = Legion::Extensions::Volition::Client.new

# Form intentions from cognitive state
result = client.form_intentions(
  tick_results: {
    emotional_evaluation: { valence: 0.3, arousal: 0.8 },
    gut_instinct:         { signal: :heightened },
    prediction_engine:    { confidence: 0.3 }
  },
  cognitive_state: {
    curiosity:  { intensity: 0.7, active_count: 4, top_question: 'Why are traces sparse?' },
    reflection: { health: 0.6, pending_adaptations: 2 }
  }
)
# => { drives: { curiosity: 0.59, corrective: 0.51, urgency: 0.55, ... },
#      dominant_drive: :curiosity,
#      current_intention: { goal: "Why are traces sparse?", drive: :curiosity, ... } }

# Check current will
client.current_intention
# => { has_will: true, goal: "Why are traces sparse?", drive: :curiosity }
```

## Drive Sources

| Drive | Source | What It Means |
|-------|--------|---------------|
| `:curiosity` | lex-curiosity wonder intensity + count | Knowledge seeking |
| `:corrective` | lex-reflection health gap + pending adaptations | Self-improvement |
| `:urgency` | lex-emotion arousal + gut signal | Urgent response |
| `:epistemic` | lex-prediction confidence gap + pending count | Uncertainty reduction |
| `:social` | lex-trust composite + lex-mesh peer count | Collaborative engagement |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
