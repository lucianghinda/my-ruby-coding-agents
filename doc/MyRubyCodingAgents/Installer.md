# Class MyRubyCodingAgents::Installer <a id="class-MyRubyCodingAgents-Installer"></a>

|  |  |
| --- | --- |
| **Inherits** | Object |
| **Defined in** | lib/my_ruby_coding_agents/installer.rb |

Writes planned files and reports the state of each one.

## Constants
### `CLEAN_STATES` <a id="constant-CLEAN_STATES"></a> <a id="CLEAN_STATES-constant"></a>
Not documented.

### `END_MARKER` <a id="constant-END_MARKER"></a> <a id="END_MARKER-constant"></a>
Not documented.

### `SKIP_REASONS` <a id="constant-SKIP_REASONS"></a> <a id="SKIP_REASONS-constant"></a>
Not documented.

### `START_MARKER` <a id="constant-START_MARKER"></a> <a id="START_MARKER-constant"></a>
Not documented.

### `STATUS_LABELS` <a id="constant-STATUS_LABELS"></a> <a id="STATUS_LABELS-constant"></a>
Not documented.

### `WRITE_VERBS` <a id="constant-WRITE_VERBS"></a> <a id="WRITE_VERBS-constant"></a>
Not documented.

## Public Instance Methods
### `initialize(dir:, agents:, instructions:, targets:)` <a id="method-i-initialize"></a> <a id="initialize-instance_method"></a>
- **@return** [Installer] a new instance of Installer

### `install(out:, force: false, dry_run: false)` <a id="method-i-install"></a> <a id="install-instance_method"></a>
Writes missing and outdated files. Edited agent files are kept unless force is
true. Returns the number of planned files.

### `status(out:)` <a id="method-i-status"></a> <a id="status-instance_method"></a>
Prints one state line per planned file. Returns true when nothing needs an
install.
