# Module MyRubyCodingAgents::InstructionFile <a id="module-MyRubyCodingAgents-InstructionFile"></a>

|  |  |
| --- | --- |
| **Defined in** | lib/my_ruby_coding_agents/instruction_file.rb |

Builds AGENTS.md and CLAUDE.md content with the managed delegation block.

## Constants
### `BLOCK` <a id="constant-BLOCK"></a> <a id="BLOCK-constant"></a>
Not documented.

### `END_MARKER` <a id="constant-END_MARKER"></a> <a id="END_MARKER-constant"></a>
Not documented.

### `IMPORT` <a id="constant-IMPORT"></a> <a id="IMPORT-constant"></a>
A CLAUDE.md line that imports AGENTS.md in Claude Code.

### `START_MARKER` <a id="constant-START_MARKER"></a> <a id="START_MARKER-constant"></a>
Not documented.

## Public Class Methods
### `block?(content)` <a id="method-c-block-3F"></a> <a id="block?-class_method"></a>
- **@return** [Boolean]

### `imports_agents?(path)` <a id="method-c-imports_agents-3F"></a> <a id="imports_agents?-class_method"></a>
- **@return** [Boolean]

### `render(existing, instructions)` <a id="method-c-render"></a> <a id="render-class_method"></a>
Replaces the block in existing content, or appends it. existing may be nil.
