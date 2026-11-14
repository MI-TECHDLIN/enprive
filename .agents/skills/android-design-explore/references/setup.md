# Previewer app setup

Read this when the `android_design_preview` tools are unavailable. Tell the user these two steps, then wait:

1. Build and install the app from a checkout of the android-design repository: `cd app && ./gradlew :app:installApp`, which installs `~/Applications/AndroidDesignPreview.app`.
2. Register it for their harness, then restart the session (`<binary>` is `~/Applications/AndroidDesignPreview.app/Contents/MacOS/AndroidDesignPreview`, written as an absolute path where the harness does not expand `~`):
   - Claude Code: `claude mcp add --scope user android_design_preview -- <binary>`
   - Codex: a `[mcp_servers.android_design_preview]` table in `~/.codex/config.toml` with `command = "<binary>"` and `default_tools_approval_mode = "approve"`
   - Antigravity: `agy mcp add android_design_preview <binary>`
