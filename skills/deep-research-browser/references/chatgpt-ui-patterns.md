# ChatGPT UI Element Patterns

Natural language queries for the `mcp__claude-in-chrome__find` tool that reliably identify ChatGPT UI elements. Update this document when UI changes break identification.

## Composer / Message Input

Primary queries (try in order):
1. `"message input"`
2. `"Send a message"`
3. `"prompt textarea"`
4. `"chat input"`

## Send / Submit Button

Primary queries:
1. `"send button"`
2. `"submit"`
3. `"send message"`

Note: The send button may be disabled until text is entered.

## File Attachment

**Use JavaScript injection, NOT native file dialog.** The native macOS file dialog cannot be controlled through browser MCP tools (keyboard commands go to the browser, not the OS dialog).

JavaScript file upload (tested 2026-03-24):
```javascript
// File input ID: 'upload-files' (accepts any type, multiple: true)
// Image input ID: 'upload-photos' (accepts image/* only)
const fileInput = document.getElementById('upload-files');
const dataTransfer = new DataTransfer();
dataTransfer.items.add(file); // file = new File([blob], name, {type})
fileInput.files = dataTransfer.files;
fileInput.dispatchEvent(new Event('change', { bubbles: true }));
```

Verification: look for attachment chip showing `"<filename> — Document"` in the composer.

## Model Selector

The authoritative model selector is the **"ChatGPT v" dropdown in the top banner**, NOT the sub-mode chip in the composer.

To open the dropdown:
1. `"Model selector"` — finds the button with accessible name "Model selector"

Dropdown options (as of 2026-03-24):
- **Latest** — auto-selects best model
- **Instant** — "For everyday chats"
- **Thinking** — "For complex questions"
- **Pro** — "Research-grade intelligence" (required for Deep Research)
- **Configure...** — opens settings

To select Pro:
1. Click "Model selector" button to open dropdown
2. `"Pro"` — finds the Pro menu item
3. Click it (checkmark appears next to selected model)

The composer area shows the active sub-mode (e.g., `"Extended Pro v"`, `"Thinking v"`), but this is NOT the model selector — it controls sub-mode within the selected model.

## Deep Research Mode

Activation queries (for autocomplete after typing `/deep`):
1. `"Deep research"`
2. `"deep research"`
3. `"Deep Research"`

Plan modal queries:
1. `"Start research"` — the confirmation button after the research plan appears
2. `"Edit"` — to modify the research plan before starting
3. `"Cancel"` — to abort

## Response / Completion Detection

Response container queries:
1. `"assistant message"`
2. `"response"`

Completion indicators (presence = research finished):
1. `"sources"` — Deep Research responses include a sources section
2. `"citations"` — alternative phrasing for sources

Still-running indicators (presence = NOT done):
1. `"Stop"` — stop button visible during generation
2. `"Stop generating"` — alternative phrasing
3. `"Researching"` — progress indicator

## Login / Auth Detection

If these elements are found, the user is NOT logged in:
1. `"Log in"`
2. `"Sign up"`
3. `"login button"`

If the composer (`"message input"`) is found, the user IS logged in.

## JavaScript Selectors

```javascript
// File inputs (tested 2026-03-24)
document.getElementById('upload-files')   // any file type, multiple: true
document.getElementById('upload-photos')  // image/* only
document.getElementById('upload-camera')  // image/* only

// Response text (last assistant message)
document.querySelectorAll('[data-message-author-role="assistant"]')

// Current URL (for saving conversation reference)
window.location.href
```
