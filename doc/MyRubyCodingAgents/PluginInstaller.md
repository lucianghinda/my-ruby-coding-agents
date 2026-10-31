# Class MyRubyCodingAgents::PluginInstaller <a id="class-MyRubyCodingAgents-PluginInstaller"></a>

|  |  |
| --- | --- |
| **Inherits** | Object |
| **Defined in** | lib/my_ruby_coding_agents/plugin_installer.rb |

Installs the advisor plugin into Codex and Claude Code by running each tool's
own marketplace and plugin commands. Both tools accept repeated runs, so an
install can be rerun safely.

## Constants
### `COMMANDS` <a id="constant-COMMANDS"></a> <a id="COMMANDS-constant"></a>
Not documented.

### `DEFAULT_RUNNER` <a id="constant-DEFAULT_RUNNER"></a> <a id="DEFAULT_RUNNER-constant"></a>
Runs a command in dir. Returns [output, success] or nil when the executable is
not on PATH.

### `DEFAULT_SOURCE` <a id="constant-DEFAULT_SOURCE"></a> <a id="DEFAULT_SOURCE-constant"></a>
Not documented.

### `MARKETPLACE` <a id="constant-MARKETPLACE"></a> <a id="MARKETPLACE-constant"></a>
Not documented.

### `PLUGIN` <a id="constant-PLUGIN"></a> <a id="PLUGIN-constant"></a>
Not documented.

## Public Instance Methods
### `initialize(dir:, targets:, source: DEFAULT_SOURCE, runner: DEFAULT_RUNNER)` <a id="method-i-initialize"></a> <a id="initialize-instance_method"></a>
- **@return** [PluginInstaller] a new instance of PluginInstaller

### `install(out:, dry_run: false)` <a id="method-i-install"></a> <a id="install-instance_method"></a>
Runs the commands for every target. Returns true when none failed. A tool
missing from PATH is skipped, not failed.
