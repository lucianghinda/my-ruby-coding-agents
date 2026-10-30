# Class MyRubyCodingAgents::Planner::Entry <a id="class-MyRubyCodingAgents-Planner-Entry"></a>

|  |  |
| --- | --- |
| **Inherits** | Data |
| **Defined in** | lib/my_ruby_coding_agents/planner.rb |

state is one of :missing, :up_to_date, :outdated, :edited (agent files),
:missing_block, :up_to_date, :outdated (instruction files), or :imported
(CLAUDE.md that imports AGENTS.md). note is extra text for output.

## Attributes
### `content` [R] <a id="attribute-i-content"></a> <a id="content-instance_method"></a>
Returns the value of attribute content
- **@return** [Object] the current value of content

### `kind` [R] <a id="attribute-i-kind"></a> <a id="kind-instance_method"></a>
Returns the value of attribute kind
- **@return** [Object] the current value of kind

### `note` [R] <a id="attribute-i-note"></a> <a id="note-instance_method"></a>
Returns the value of attribute note
- **@return** [Object] the current value of note

### `path` [R] <a id="attribute-i-path"></a> <a id="path-instance_method"></a>
Returns the value of attribute path
- **@return** [Object] the current value of path

### `state` [R] <a id="attribute-i-state"></a> <a id="state-instance_method"></a>
Returns the value of attribute state
- **@return** [Object] the current value of state
