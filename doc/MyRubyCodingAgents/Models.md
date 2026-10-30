# Class MyRubyCodingAgents::Models <a id="class-MyRubyCodingAgents-Models"></a>

|  |  |
| --- | --- |
| **Inherits** | Object |
| **Defined in** | lib/my_ruby_coding_agents/models.rb |

Model tier table loaded from models.yml. Maps a tier name to the model and
reasoning effort each tool uses.

## Constants
### `TIER_KEYS` <a id="constant-TIER_KEYS"></a> <a id="TIER_KEYS-constant"></a>
Not documented.

### `TOOL_KEYS` <a id="constant-TOOL_KEYS"></a> <a id="TOOL_KEYS-constant"></a>
Not documented.

## Public Class Methods
### `load(path)` <a id="method-c-load"></a> <a id="load-class_method"></a>
Not documented.

### `parse(source)` <a id="method-c-parse"></a> <a id="parse-class_method"></a>
Not documented.

## Public Instance Methods
### `fetch(name)` <a id="method-i-fetch"></a> <a id="fetch-instance_method"></a>
Not documented.

### `initialize(table)` <a id="method-i-initialize"></a> <a id="initialize-instance_method"></a>
- **@raise** [ArgumentError]
- **@return** [Models] a new instance of Models

### `names()` <a id="method-i-names"></a> <a id="names-instance_method"></a>
Tier names in file order.

### `routing(agents)` <a id="method-i-routing"></a> <a id="routing-instance_method"></a>
One sentence per used tier: its purpose, models, and agents. Tiers keep file
order and agents are sorted by name, so output is stable.
