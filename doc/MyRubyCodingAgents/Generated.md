# Module MyRubyCodingAgents::Generated <a id="module-MyRubyCodingAgents-Generated"></a>

|  |  |
| --- | --- |
| **Defined in** | lib/my_ruby_coding_agents/generated.rb |

Marks rendered agent files with a hash of their content, so a later install
can tell an untouched generated file from one a person edited.

## Constants
### `FRONTMATTER` <a id="constant-FRONTMATTER"></a> <a id="FRONTMATTER-constant"></a>
Not documented.

### `MARKER` <a id="constant-MARKER"></a> <a id="MARKER-constant"></a>
Not documented.

### `NAME` <a id="constant-NAME"></a> <a id="NAME-constant"></a>
Not documented.

## Public Class Methods
### `digest(content)` <a id="method-c-digest"></a> <a id="digest-class_method"></a>
Not documented.

### `stamp(content, style:)` <a id="method-c-stamp"></a> <a id="stamp-class_method"></a>
Adds the marker line. style is :toml (first line) or :markdown (right after
the frontmatter). The hash covers the content without the marker line.

### `status(existing_content)` <a id="method-c-status"></a> <a id="status-class_method"></a>
:unmodified when the marker hash matches the rest of the file, :modified when
it does not, :foreign when there is no marker.
