# Module MyRubyCodingAgents::Templates <a id="module-MyRubyCodingAgents-Templates"></a>

|  |  |
| --- | --- |
| **Defined in** | lib/my_ruby_coding_agents/templates.rb |

Loads the bundled templates: the model tier table, the agents, and the
delegation instructions.

## Constants
### `AGENTS_DIR` <a id="constant-AGENTS_DIR"></a> <a id="AGENTS_DIR-constant"></a>
Not documented.

### `INSTRUCTIONS_PATH` <a id="constant-INSTRUCTIONS_PATH"></a> <a id="INSTRUCTIONS_PATH-constant"></a>
Not documented.

### `MODELS_PATH` <a id="constant-MODELS_PATH"></a> <a id="MODELS_PATH-constant"></a>
Not documented.

### `ROOT` <a id="constant-ROOT"></a> <a id="ROOT-constant"></a>
Not documented.

### `ROUTING_PLACEHOLDER` <a id="constant-ROUTING_PLACEHOLDER"></a> <a id="ROUTING_PLACEHOLDER-constant"></a>
Not documented.

## Public Class Methods
### `agents(models)` <a id="method-c-agents"></a> <a id="agents-class_method"></a>
Agents sorted by file name, with models resolved from their tiers.

### `instructions(models, agents)` <a id="method-c-instructions"></a> <a id="instructions-class_method"></a>
Instructions with the routing placeholder replaced by a sentence built from
the tier table and the agents' tiers.

### `models()` <a id="method-c-models"></a> <a id="models-class_method"></a>
Not documented.
