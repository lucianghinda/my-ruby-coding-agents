# Class MyRubyCodingAgents::Agent <a id="class-MyRubyCodingAgents-Agent"></a>

|  |  |
| --- | --- |
| **Inherits** | Object |
| **Defined in** | lib/my_ruby_coding_agents/agent.rb |

Parsed metadata and shared instruction body for one agent template. Models and
efforts come from the agent's tier in the Models table.

## Constants
### `FIELDS` <a id="constant-FIELDS"></a> <a id="FIELDS-constant"></a>
Not documented.

### `REQUIRED_FIELDS` <a id="constant-REQUIRED_FIELDS"></a> <a id="REQUIRED_FIELDS-constant"></a>
Not documented.

## Attributes
### `body` [R] <a id="attribute-i-body"></a> <a id="body-instance_method"></a>
Returns the value of attribute body.

### `description` [R] <a id="attribute-i-description"></a> <a id="description-instance_method"></a>
Returns the value of attribute description.

### `name` [R] <a id="attribute-i-name"></a> <a id="name-instance_method"></a>
Returns the value of attribute name.

### `tier` [R] <a id="attribute-i-tier"></a> <a id="tier-instance_method"></a>
Returns the value of attribute tier.

### `tools` [R] <a id="attribute-i-tools"></a> <a id="tools-instance_method"></a>
Returns the value of attribute tools.

## Public Class Methods
### `load(path, models:)` <a id="method-c-load"></a> <a id="load-class_method"></a>
Not documented.

### `parse(source, models:)` <a id="method-c-parse"></a> <a id="parse-class_method"></a>
Not documented.

## Public Instance Methods
### `claude_effort()` <a id="method-i-claude_effort"></a> <a id="claude_effort-instance_method"></a>
Not documented.

### `claude_model()` <a id="method-i-claude_model"></a> <a id="claude_model-instance_method"></a>
Not documented.

### `codex_effort()` <a id="method-i-codex_effort"></a> <a id="codex_effort-instance_method"></a>
Not documented.

### `codex_model()` <a id="method-i-codex_model"></a> <a id="codex_model-instance_method"></a>
Not documented.

### `initialize(name:, description:, tier:, tools:, body:)` <a id="method-i-initialize"></a> <a id="initialize-instance_method"></a>
tier is a Models::Tier.
- **@return** [Agent] a new instance of Agent
