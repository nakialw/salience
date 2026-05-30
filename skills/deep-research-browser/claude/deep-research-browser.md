---
argument-hint: <source directory/files and prompt for ChatGPT Deep Research>
---

Run ChatGPT Extended Pro Deep Research via browser automation:

$ARGUMENTS

## Instructions

You are automating ChatGPT's web-only Deep Research mode using `claude-in-chrome` MCP browser tools. This skill submits files and prompts to ChatGPT Deep Research via the browser and captures the response back to a local output bundle.

Before calling any `mcp__claude-in-chrome__*` tool, you MUST first load it using `ToolSearch` with `select:mcp__claude-in-chrome__<tool_name>`.

Read the reference file at `~/.claude/commands/references/deep-research-browser/chatgpt-ui-patterns.md` for UI element identification patterns.

### Step 1: Parse arguments and determine mode

Parse the arguments to extract:
- **Source directory**: path containing files to upload (optional)
- **Prompt text**: the research question or instructions
- **Flags**: `--poll` (check status of a running job), `--mode normal` (skip Deep Research, use standard mode)

If `--poll` is present, skip to Step 8 (Poll mode).

If a source directory is provided:
- Validate it exists using `ls` via Bash
- List all files with sizes: `ls -lh <directory>`
- If more than 10 files, warn the user and ask which files to include (ChatGPT limits uploads to ~10 files)

Create the output bundle directory:
```bash
BUNDLE_DIR="$HOME/.openclaw/workspace/outputs/llm-jobs/$(date +%Y%m%d-%H%M%S)-chatgpt-deep-research"
mkdir -p "$BUNDLE_DIR"
```

Write `request.md` to the bundle immediately with: prompt text, mode, file manifest (names + sizes), timestamp.

### Step 2: Establish browser session

1. Load and call `mcp__claude-in-chrome__tabs_context_mcp` to get current tabs
2. Check if any existing tab is on `chatgpt.com`
   - If yes: reuse that tab
   - If no: load and call `mcp__claude-in-chrome__tabs_create_mcp`, then load and call `mcp__claude-in-chrome__navigate` to `https://chatgpt.com`
3. Load and call `mcp__claude-in-chrome__computer` with action `screenshot` to verify page state

### Step 3: Detect login state and verify model

1. Load and call `mcp__claude-in-chrome__read_page` to get the accessibility tree
2. Load and call `mcp__claude-in-chrome__find` with query `"message input"` to check for the composer

**If the composer is NOT found** (login required):
- Run via Bash: `terminal-notifier -title "ChatGPT Login Required" -subtitle "Manual intervention needed" -message "Please log in to chatgpt.com, then reply 'done'." -group openclaw-browser-auth -sound default`
- Tell the user login is required and wait for them to reply "done"
- After they reply, take another screenshot to verify login succeeded

**Verify and set model to Pro:**
1. Use `mcp__claude-in-chrome__find` with query `"Model selector"` to find the ChatGPT model dropdown button (it's in the top banner, labeled "ChatGPT v")
2. Click it to open the dropdown (options: Latest, Instant, Thinking, Pro, Configure...)
3. Take a screenshot to see which model has a checkmark
4. If "Pro" is NOT checked, use `mcp__claude-in-chrome__find` with query `"Pro"` and click the "Pro" menu item to select it
5. If "Pro" IS already checked, click elsewhere to close the dropdown
6. If the model selector cannot be found, alert the user and halt

Note: The composer area shows the currently active sub-mode (e.g., "Extended Pro v", "Thinking v"). The top "ChatGPT v" dropdown is the authoritative model selector. Deep Research requires "Pro" mode.

### Step 4: Activate Deep Research mode

Skip this step if `--mode normal` was specified.

1. Use `mcp__claude-in-chrome__find` with query `"message input"` to locate the composer
2. Click the composer to focus it using `mcp__claude-in-chrome__computer` (action: `left_click`)
3. Type `/deep` using `mcp__claude-in-chrome__computer` (action: `type`, text: `/deep`)
4. Wait 2 seconds for the autocomplete menu using `mcp__claude-in-chrome__computer` (action: `wait`, duration: 2)
5. Use `mcp__claude-in-chrome__find` with query `"Deep research"` to find the autocomplete option. IMPORTANT: `find` will return multiple matches including sidebar links. Select the match that is a `generic` text element in the active chat interface (NOT a sidebar `link`). Look for the one described as being "in active chat interface" or near the composer.
6. Click it using `mcp__claude-in-chrome__computer` (action: `left_click`)
7. Take a screenshot to verify the Deep Research mode chip is visible (chip shows "Deep research" with an `x` dismiss button below the composer text area)

If the autocomplete option is not found, try alternative queries: `"deep research"`, `"Deep Research"`. If still not found, alert the user.

### Step 5: Upload files

Skip this step if no source directory was provided.

**Use JavaScript DataTransfer injection** (tested and confirmed working). Native macOS file dialogs cannot be controlled through browser MCP tools.

For each file in the source directory:

1. Read the file content using Claude's Read tool (for text files) or Bash `base64 <filepath>` (for binary files like PDFs)
2. Use `mcp__claude-in-chrome__javascript_tool` to inject the file into the `#upload-files` input:

For text files:
```javascript
const content = `<file content here>`;
const blob = new Blob([content], { type: '<mime-type>' });
const file = new File([blob], '<filename>', { type: '<mime-type>', lastModified: Date.now() });
const fileInput = document.getElementById('upload-files');
const dataTransfer = new DataTransfer();
dataTransfer.items.add(file);
fileInput.files = dataTransfer.files;
const changeEvent = new Event('change', { bubbles: true });
fileInput.dispatchEvent(changeEvent);
'Uploaded: ' + fileInput.files[0].name;
```

For binary files (PDFs, images), base64 encode first via Bash, then:
```javascript
const b64 = `<base64 string>`;
const byteChars = atob(b64);
const byteArray = new Uint8Array(byteChars.length);
for (let i = 0; i < byteChars.length; i++) byteArray[i] = byteChars.charCodeAt(i);
const blob = new Blob([byteArray], { type: 'application/pdf' });
const file = new File([blob], '<filename>', { type: 'application/pdf', lastModified: Date.now() });
const fileInput = document.getElementById('upload-files');
const dataTransfer = new DataTransfer();
dataTransfer.items.add(file);
fileInput.files = dataTransfer.files;
const changeEvent = new Event('change', { bubbles: true });
fileInput.dispatchEvent(changeEvent);
'Uploaded: ' + fileInput.files[0].name;
```

For multiple files, accumulate all File objects in the same DataTransfer before setting `.files` and dispatching the event.

3. Wait 2 seconds for the upload to process
4. Take a screenshot to verify the attachment chip appeared (look for `"<filename> — Document"` chip in the composer)

If an attachment chip does not appear after a file upload attempt:
- Log the failure in the run report
- Alert the user and ask whether to continue with remaining files or abort

After all files are uploaded, take a final screenshot to confirm all attachment chips are visible.

**Size limits**: JavaScript string literals have practical limits. For files larger than ~5MB, warn the user that upload may fail and suggest they manually attach via the browser.

### Step 6: Enter prompt and submit

1. Use `mcp__claude-in-chrome__find` with query `"message input"` to locate the composer textarea
2. Click it using `mcp__claude-in-chrome__computer` (action: `left_click`) to focus
3. Type the prompt text using `mcp__claude-in-chrome__computer` (action: `type`, text: `<prompt>`)
   - For prompts longer than 2000 characters, type in chunks of 2000 characters with a 1-second wait between chunks
4. Take a screenshot to verify the prompt is entered correctly
5. Use `mcp__claude-in-chrome__find` with query `"send button"` to locate the submit button. If not found, try `"submit"`.
6. Click the send button using `mcp__claude-in-chrome__computer` (action: `left_click`)
7. Wait 5 seconds for the response to begin

### Step 7: Handle Deep Research plan modal

If Deep Research mode is active (not `--mode normal`):

1. Poll for the "Start research" button:
   - Use `mcp__claude-in-chrome__find` with query `"Start research"` every 5 seconds
   - Continue polling for up to 60 seconds
2. When found, click "Start research" using `mcp__claude-in-chrome__computer` (action: `left_click`)
3. Wait 3 seconds
4. Take a screenshot to confirm research has started
5. Capture the conversation URL using `mcp__claude-in-chrome__javascript_tool` with expression: `window.location.href`
6. Append the conversation URL and start timestamp to `run_report.md` in the output bundle

If "Start research" is not found within 60 seconds:
- Take a screenshot
- Alert the user that the Deep Research plan modal did not appear (ChatGPT may have treated it as a normal query)

### Step 8: Submit/poll split

**Submit mode** (default — no `--poll` flag):

After completing Steps 1-7, report to the user:
- The conversation URL
- The output bundle directory path
- Tell them: "Deep Research is running. Run `/deep-research-browser --poll` to check status and capture results."

Stop here. Do not block the session.

**Poll mode** (`--poll` flag):

1. Find the most recent output bundle:
   ```bash
   ls -td ~/.openclaw/workspace/outputs/llm-jobs/*-chatgpt-deep-research/ | head -1
   ```
2. Read `run_report.md` from that bundle to get the conversation URL
3. Load and call `mcp__claude-in-chrome__tabs_context_mcp` to get current tabs
4. Navigate to the saved conversation URL using `mcp__claude-in-chrome__navigate`
5. Wait 5 seconds for the page to load
6. Check completion status:
   - Use `mcp__claude-in-chrome__find` with query `"sources"` or `"citations"` — Deep Research responses always include these
   - Use `mcp__claude-in-chrome__find` with query `"Stop"` — presence means still running
   - Load and call `mcp__claude-in-chrome__get_page_text` — if substantial content is present beyond the original prompt, research is likely complete
7. If NOT complete:
   - Take a screenshot showing current progress
   - Report status to the user (e.g., "Still researching. X sources found so far.")
   - Tell them to poll again later
   - Stop here
8. If COMPLETE: proceed to Step 9

### Step 9: Capture output

1. **Primary method** — use `mcp__claude-in-chrome__javascript_tool` to extract the response via `[class*="prose"]` selector (tested and confirmed working 2026-03-24):
   ```javascript
   const proseDivs = document.querySelectorAll('[class*="prose"]');
   const allTexts = Array.from(proseDivs).map(m => m.innerText);
   const longest = allTexts.sort((a, b) => b.length - a.length)[0] || '';
   longest;
   ```
   This returns the longest prose block, which is the response body.

2. **Fallback** — use `mcp__claude-in-chrome__get_page_text` to extract the full page text. This includes UI chrome that must be stripped.

3. **Second fallback** — try `[class*="markdown"]` selector or `[data-message-author-role="assistant"]` (note: the latter may return empty text for some response types like "Thinking" mode).

4. If all extraction methods fail, take a screenshot and alert the user to manually copy the response

Parse the extracted text to isolate the response content (strip UI chrome, navigation elements, etc.). Save as `response_raw.md`.

### Step 10: Save output bundle and report

1. Write `response_raw.md` to the output bundle directory
2. Update `run_report.md` with the completion timestamp and a summary of actions taken
3. Write `manifest.json`:
   ```json
   {
     "status": "complete",
     "provider": "chatgpt",
     "mode": "deep-research",
     "model": "5.4-pro",
     "completed": true,
     "conversation_url": "<url>",
     "start_time": "<ISO timestamp>",
     "end_time": "<ISO timestamp>",
     "files_uploaded": ["<list of filenames>"],
     "files": ["request.md", "response_raw.md", "run_report.md"]
   }
   ```
4. If a source directory was provided, copy `response_raw.md` to that directory for easy access:
   ```bash
   cp "$BUNDLE_DIR/response_raw.md" "<source_directory>/chatgpt-deep-research-response.md"
   ```

Report to the user:
- The output bundle directory path
- The path to the copied response file (if applicable)
- A brief summary of the response (first 2-3 sentences)

## Operating Rules

- Always load MCP tools via `ToolSearch` before calling them. Every `mcp__claude-in-chrome__*` tool must be loaded first.
- Never use hardcoded CSS selectors or XPaths. Always use `find` (natural language) and `read_page` (accessibility tree) for element identification.
- Take screenshots at every critical juncture (login verification, mode activation, file upload, submission, completion) for debugging.
- Log every action with timestamps to `run_report.md`.
- If CAPTCHA, MFA, or any manual intervention is needed, immediately alert the user via `terminal-notifier` and halt until they confirm.
- If a browser tool call fails twice in a row, stop and ask the user for guidance. Do not loop.
- The conversation persists server-side even if the browser control session times out. Always reconnect via the saved URL rather than starting over.
- Recoverable errors (transport timeout, missing element on first try) get one retry. Unrecoverable errors (login wall, no tab) halt with user notification.
