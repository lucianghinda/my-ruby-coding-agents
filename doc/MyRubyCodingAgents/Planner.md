# Class MyRubyCodingAgents::Planner <a id="class-MyRubyCodingAgents-Planner"></a>

|  |  |
| --- | --- |
| **Inherits** | Object |
| **Defined in** | lib/my_ruby_coding_agents/planner.rb |

Works out which files an install would touch and the state of each one.
Install and status share this plan.

## Constants
### `TARGETS` <a id="constant-TARGETS"></a> <a id="TARGETS-constant"></a>
Not documented.

## Public Instance Methods
### `entries()` <a id="method-i-entries"></a> <a id="entries-instance_method"></a>
Entries in install order. A linked CLAUDE.md and AGENTS.md refer to the same
file, so only the first entry for a real path is kept.

### `initialize(root:, agents:, instructions:, targets:)` <a id="method-i-initialize"></a> <a id="initialize-instance_method"></a>
- **@return** [Planner] a new instance of Planner
