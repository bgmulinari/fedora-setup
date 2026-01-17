# Neovim Manual for .NET Developers

A comprehensive guide for developers transitioning from Visual Studio or JetBrains Rider to Neovim. This manual covers everything from basic vim concepts to the full .NET development workflow.

---

## Table of Contents

1. [Part 1: Vim/Neovim Fundamentals](#part-1-vimneovim-fundamentals)
2. [Part 2: LazyVim & This Configuration](#part-2-lazyvim--this-configuration)
3. [Part 3: IDE Features (LSP)](#part-3-ide-features-lsp)
4. [Part 4: .NET Development](#part-4-net-development)
5. [Part 5: Custom Keybindings Quick Reference](#part-5-custom-keybindings-quick-reference)
6. [Part 6: Visual Studio/Rider Comparison](#part-6-visual-studiorider-comparison)

---

## Part 1: Vim/Neovim Fundamentals

### Understanding Modal Editing

Unlike VS/Rider where you're always in "typing mode," Neovim has distinct **modes**. This is the core concept that makes vim so powerful - different keys do different things depending on the mode.

#### The Four Main Modes

| Mode | Purpose | How to Enter | Visual Indicator |
|------|---------|--------------|------------------|
| **Normal** | Navigation and commands | `Esc` or `jk` | No indicator (default) |
| **Insert** | Typing text | `i`, `a`, `o`, etc. | `-- INSERT --` |
| **Visual** | Selecting text | `v`, `V`, `Ctrl+v` | `-- VISUAL --` |
| **Command-line** | Ex commands | `:` or `;` | `:` at bottom |

**Key Insight**: You'll spend most of your time in **Normal mode**, not Insert mode. This is the opposite of VS/Rider where you're always ready to type.

#### Switching Between Modes

```
Normal ──────────────────────────────────────────────────────┐
   │                                                         │
   │  i, a, o, etc.          v, V, Ctrl+v         :  or  ;   │
   ▼                              ▼                    ▼     │
Insert                        Visual              Command    │
   │                              │                    │     │
   └──── Esc or jk ──────────────┴──── Esc ───────────┴─────┘
```

**This config**: Press `jk` quickly (in sequence) to exit Insert mode. This is faster than reaching for Escape.

---

### Basic Movement

Think of movement as a language. You'll combine these with operators later.

#### Character Movement

| Key | Action |
|-----|--------|
| `h` | Move left |
| `j` | Move down |
| `k` | Move up |
| `l` | Move right |

**Tip**: `j` looks like a down arrow. Use this to remember j=down, k=up.

#### Word Movement

| Key | Action |
|-----|--------|
| `w` | Jump to start of next word |
| `b` | Jump to start of previous word |
| `e` | Jump to end of current/next word |
| `W` | Jump to next WORD (whitespace-delimited) |
| `B` | Jump to previous WORD |
| `E` | Jump to end of WORD |

**Example**: In `Console.WriteLine("Hello")`, `w` treats `.` as a word boundary, but `W` jumps over the entire `Console.WriteLine("Hello")`.

#### Line Movement

| Key | Action |
|-----|--------|
| `0` | Jump to start of line |
| `^` | Jump to first non-whitespace character |
| `$` | Jump to end of line |
| `f{char}` | Jump to next occurrence of {char} on line |
| `F{char}` | Jump to previous occurrence of {char} |
| `t{char}` | Jump to just before next {char} |
| `T{char}` | Jump to just after previous {char} |
| `;` | Repeat last f/F/t/T motion |
| `,` | Repeat last f/F/t/T motion (reverse) |

**Note**: In this config, `;` is remapped to `:` for quick command mode. Use `,` to repeat f/F/t/T.

#### File Movement

| Key | Action |
|-----|--------|
| `gg` | Jump to first line of file |
| `G` | Jump to last line of file |
| `{number}G` | Jump to line {number} |
| `{` | Jump to previous paragraph/blank line |
| `}` | Jump to next paragraph/blank line |
| `%` | Jump to matching bracket `()` `[]` `{}` |

#### Screen Movement

| Key | Action |
|-----|--------|
| `Ctrl+d` | Scroll down half page |
| `Ctrl+u` | Scroll up half page |
| `Ctrl+f` | Scroll down full page |
| `Ctrl+b` | Scroll up full page |
| `H` | Jump to top of screen (High) |
| `M` | Jump to middle of screen (Middle) |
| `L` | Jump to bottom of screen (Low) |
| `zz` | Center current line on screen |
| `zt` | Move current line to top of screen |
| `zb` | Move current line to bottom of screen |

---

### Basic Editing

#### Entering Insert Mode

| Key | Action |
|-----|--------|
| `i` | Insert before cursor |
| `I` | Insert at start of line |
| `a` | Append after cursor |
| `A` | Append at end of line |
| `o` | Open new line below |
| `O` | Open new line above |
| `s` | Substitute character (delete + insert) |
| `S` | Substitute line (delete line + insert) |

**Common pattern**: To add something at the end of a line, press `A` to jump to end and enter Insert mode in one keystroke.

#### Deleting Text

| Key | Action |
|-----|--------|
| `x` | Delete character under cursor |
| `X` | Delete character before cursor |
| `dd` | Delete entire line |
| `D` | Delete from cursor to end of line |
| `d{motion}` | Delete over motion (see below) |

#### Changing Text (Delete + Enter Insert Mode)

| Key | Action |
|-----|--------|
| `cc` | Change entire line |
| `C` | Change from cursor to end of line |
| `c{motion}` | Change over motion |

#### Copy (Yank) and Paste

| Key | Action |
|-----|--------|
| `yy` | Yank (copy) entire line |
| `Y` | Yank entire line (same as `yy`) |
| `y{motion}` | Yank over motion |
| `p` | Paste after cursor |
| `P` | Paste before cursor |

**Note**: Deleted text also goes into the register, so `dd` followed by `p` moves a line.

#### Undo and Redo

| Key | Action |
|-----|--------|
| `u` | Undo |
| `Ctrl+r` | Redo |
| `.` | Repeat last change |

**Pro tip**: The `.` command is incredibly powerful. Make a change once, then press `.` to repeat it elsewhere.

---

### Operators & Motions: The Vim Grammar

This is where vim becomes powerful. Commands follow a grammar:

```
{operator} {count} {motion}
```

Or:

```
{operator} {text-object}
```

#### Common Operators

| Operator | Action |
|----------|--------|
| `d` | Delete |
| `c` | Change (delete + enter Insert mode) |
| `y` | Yank (copy) |
| `>` | Indent right |
| `<` | Indent left |
| `=` | Auto-indent |
| `gU` | Make uppercase |
| `gu` | Make lowercase |

#### Text Objects

Text objects define regions of text. They come in two flavors:
- `i` = "inner" (inside, excludes delimiters)
- `a` = "a/around" (includes delimiters)

| Text Object | What It Selects |
|-------------|-----------------|
| `iw` / `aw` | Inner/around word |
| `iW` / `aW` | Inner/around WORD |
| `i"` / `a"` | Inner/around double quotes |
| `i'` / `a'` | Inner/around single quotes |
| `i)` / `a)` | Inner/around parentheses |
| `i]` / `a]` | Inner/around brackets |
| `i}` / `a}` | Inner/around braces |
| `i>` / `a>` | Inner/around angle brackets |
| `it` / `at` | Inner/around XML/HTML tags |
| `ip` / `ap` | Inner/around paragraph |
| `is` / `as` | Inner/around sentence |

#### Examples in Practice

| Command | What It Does |
|---------|--------------|
| `diw` | Delete inner word (keep surrounding spaces) |
| `daw` | Delete a word (including one space) |
| `ci"` | Change inside quotes (delete content, enter Insert) |
| `ca"` | Change around quotes (delete content + quotes) |
| `yi{` | Yank everything inside braces |
| `>ip` | Indent current paragraph |
| `gUiw` | Make current word UPPERCASE |
| `d2w` | Delete 2 words |
| `c3j` | Change current line and 3 lines below |

**Real-world example**: Your cursor is on a method name `GetUser`. To rename it:
1. `ciw` - Change inner word (deletes `GetUser`, enters Insert mode)
2. Type new name
3. Press `Esc` or `jk`

---

### Visual Mode

Visual mode lets you select text, then apply operators.

| Key | Mode |
|-----|------|
| `v` | Character-wise visual |
| `V` | Line-wise visual |
| `Ctrl+v` | Block-wise visual (column selection) |

Once in visual mode:
- Use any motion to extend selection
- Press an operator (`d`, `c`, `y`, etc.) to act on selection
- Press `o` to jump to other end of selection
- Press `Esc` or `jk` to cancel

**Block selection example**: To add `//` to the start of 10 lines:
1. `Ctrl+v` to enter block mode
2. `9j` to extend down 9 lines
3. `I` to insert at start of block
4. Type `// `
5. Press `Esc` - the change applies to all lines

---

### Buffers, Windows, and Tabs

#### Buffers = Files in Memory

A buffer is a file loaded into memory. You can have many buffers open.

| Command | Action |
|---------|--------|
| `:e {file}` | Edit/open a file |
| `:ls` | List all buffers |
| `:b {number}` | Switch to buffer by number |
| `:b {name}` | Switch to buffer by partial name |
| `:bn` | Next buffer |
| `:bp` | Previous buffer |
| `:bd` | Close buffer (delete) |
| `<S-Tab>` | **This config**: Switch to previous buffer |

#### Windows = Viewports

Windows are views into buffers. Multiple windows can show the same buffer.

| Command | Action |
|---------|--------|
| `Ctrl+w s` | Split window horizontally |
| `Ctrl+w v` | Split window vertically |
| `Ctrl+w h/j/k/l` | Navigate to window left/down/up/right |
| `Ctrl+w c` | Close current window |
| `Ctrl+w o` | Close all other windows |
| `Ctrl+w =` | Make all windows equal size |

#### Tabs = Collections of Windows

Tabs contain window layouts. Less commonly used in Neovim.

| Command | Action |
|---------|--------|
| `:tabnew` | New tab |
| `:tabn` | Next tab |
| `:tabp` | Previous tab |
| `gt` | Next tab |
| `gT` | Previous tab |

---

### Search and Replace

#### Basic Search

| Key | Action |
|-----|--------|
| `/{pattern}` | Search forward |
| `?{pattern}` | Search backward |
| `n` | Next match |
| `N` | Previous match |
| `*` | Search for word under cursor (forward) |
| `#` | Search for word under cursor (backward) |

#### Search and Replace

```vim
:s/old/new/       " Replace first occurrence on current line
:s/old/new/g      " Replace all occurrences on current line
:%s/old/new/g     " Replace all occurrences in file
:%s/old/new/gc    " Replace all with confirmation
```

**Tip**: Use `\<` and `\>` for word boundaries: `:%s/\<old\>/new/g`

---

## Part 2: LazyVim & This Configuration

### What is LazyVim?

LazyVim is a pre-configured Neovim distribution. Think of it as "Neovim with batteries included." It provides:

- Sensible defaults
- Pre-configured plugins
- A consistent keybinding scheme
- Easy customization

This config is built on LazyVim, so you get all its features plus custom .NET tooling.

### The Leader Key

The **leader key** is `<Space>`. It's used as a prefix for custom commands.

When you press `<Space>` and wait, **which-key** will show you available options:

```
┌──────────────────────────────────────┐
│ <leader>                             │
│                                      │
│ b  → Buffers                         │
│ c  → Code                            │
│ d  → Debug                           │
│ e  → Explorer                        │
│ f  → File/Find                       │
│ g  → Git                             │
│ s  → Search                          │
│ ...                                  │
└──────────────────────────────────────┘
```

**Just press Space and wait** - this is your discovery mechanism.

### Which-Key

Which-key is your best friend when learning. It shows available keybindings after you press a prefix key.

- Press `<Space>` → See all leader commands
- Press `g` → See all "go to" commands
- Press `z` → See all fold/scroll commands
- Press `[` or `]` → See all bracket navigation commands

### File Explorer (Neo-tree)

| Key | Action |
|-----|--------|
| `<leader>e` | Toggle file explorer |
| `<leader>E` | Focus file explorer |

In Neo-tree:
| Key | Action |
|-----|--------|
| `<CR>` | Open file/toggle folder |
| `a` | Add new file |
| `d` | Delete |
| `r` | Rename |
| `c` | Copy |
| `m` | Move |
| `y` | Copy path |
| `?` | Show help |

### Fuzzy Finder (Telescope)

Telescope is like VS's Quick Open but more powerful.

| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep (search in files) |
| `<leader>fb` | Browse buffers |
| `<leader>fh` | Help tags |
| `<leader>fr` | Recent files |
| `<leader>sg` | Search by grep |
| `<leader>sw` | Search current word |

In Telescope picker:
| Key | Action |
|-----|--------|
| `<CR>` | Open selection |
| `Ctrl+j/k` | Navigate up/down |
| `Ctrl+v` | Open in vertical split |
| `Ctrl+x` | Open in horizontal split |
| `Esc` | Close picker |

### Plugin Management (lazy.nvim)

| Command | Action |
|---------|--------|
| `:Lazy` | Open plugin manager |
| `:Lazy sync` | Update all plugins |
| `:Lazy health` | Check plugin health |

---

## Part 3: IDE Features (LSP)

### What is LSP?

**Language Server Protocol** is the same technology VS Code uses. A separate process (the "language server") analyzes your code and provides:

- IntelliSense/autocomplete
- Error diagnostics
- Go to definition
- Find references
- Rename refactoring
- Code actions

For C#, this config uses **Roslyn** (the same compiler VS uses).

### Hover Documentation

| Key | Action |
|-----|--------|
| `K` | Show hover information (type, docs) |

Press `K` on any symbol to see its type and documentation. Press again to enter the popup (for scrolling).

### Navigation Commands

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `F12` | Go to definition (VS-style) |
| `gi` | Go to implementation |
| `gr` | Go to references |
| `gD` | Go to declaration |
| `gy` | Go to type definition |

**Tip**: After jumping, use `Ctrl+o` to jump back to where you were.

### Refactoring

| Key | Action |
|-----|--------|
| `<leader>ra` | Rename symbol (like F2 in VS) |
| `<leader>ca` | Code actions (like Ctrl+. in VS) |

**Code actions** include:
- Generate method/constructor
- Implement interface
- Add using statement
- Extract method
- And more...

### Signature Help

| Key | Action |
|-----|--------|
| `Ctrl+k` | Show signature help (parameter info) |

This shows parameter info when you're inside a function call.

### Diagnostics

Errors and warnings appear:
- As signs in the gutter (left margin)
- As inline diagnostic messages (via tiny-inline-diagnostic)
- In the diagnostics list

| Key | Action |
|-----|--------|
| `]d` | Go to next diagnostic |
| `[d` | Go to previous diagnostic |
| `<leader>cd` | Line diagnostics |
| `<leader>xx` | Toggle diagnostics list |

Diagnostic signs:
-  = Error
-  = Warning
-  = Hint
-  = Info

---

## Part 4: .NET Development

### Roslyn LSP

The Roslyn language server provides full C# IDE features. It starts automatically when you open a `.cs` or `.razor` file.

**First time setup**: Open a C# project and wait for Roslyn to initialize. You'll see progress in the status line.

### Easy-dotnet: Solution Explorer & NuGet

| Key | Description |
|-----|-------------|
| `<leader>cs` | Easy-dotnet commands (via which-key) |

Commands available through `:Dotnet` (or via Telescope):
- `Dotnet new` - Create new project
- `Dotnet nuget` - Manage NuGet packages
- `Dotnet run` - Run project
- `Dotnet build` - Build project
- `Dotnet restore` - Restore packages
- `Dotnet test` - Run tests

### Running Tests (Neotest)

| Key | Action |
|-----|--------|
| `<leader>tt` | Run nearest test |
| `<leader>tf` | Run all tests in file |
| `<leader>ts` | Toggle test summary |
| `<leader>to` | Show test output |
| `<leader>dt` | Debug nearest test |
| `F6` | Debug nearest test |

### Debugging Workflow

This config provides full debugging support via nvim-dap and netcoredbg.

#### Debug Keybindings

| Key | Action |
|-----|--------|
| `F5` | Start debugging / Continue |
| `F9` | Toggle breakpoint |
| `F10` | Step over |
| `F11` | Step into |
| `F8` | Step out |
| `<leader>du` | Toggle debug UI |
| `<leader>dr` | Open REPL |
| `<leader>dl` | Run last debug configuration |
| `Q` | Peek variable value (hover) |
| `<leader>dw` | Add to watches |

#### Starting a Debug Session

1. Set breakpoints with `F9` (you'll see ⚪ in the gutter)
2. Press `F5` to start debugging
3. Enter the path to your DLL when prompted
4. The Debug UI will open automatically

#### Debug UI Layout

When debugging starts, you'll see:
- **Scopes panel** (bottom): Shows local variables, arguments
- **Breakpoint indicator**: 🔴 shows current execution line

#### Inspecting Variables

- **Hover**: Press `Q` on any variable to see its value
- **Add to watches**: Press `<leader>dw` to track a variable
- **REPL**: Press `<leader>dr` to open interactive REPL

#### Ending a Debug Session

- Press `F5` to continue to the end
- Or use `:DapTerminate` to stop
- Debug UI closes automatically

### Code Formatting

**CSharpier** auto-formats your C# code on save. The format style is consistent with .NET conventions.

To format manually:
- `:Format` or `<leader>cf`

### Snippets

This config includes LuaSnip with C# snippets.

In Insert mode, type a trigger and press `Tab` to expand:

| Trigger | Expansion |
|---------|-----------|
| `/// summary` | XML doc comment block |

LazyVim also loads friendly-snippets which includes many C# snippets:
- `ctor` → Constructor
- `prop` → Property
- `class` → Class definition
- And many more...

---

## Part 5: Custom Keybindings Quick Reference

### Mode Legend

- `n` = Normal mode
- `i` = Insert mode
- `v` = Visual mode
- `x` = Visual mode (character-wise)

### General

| Key | Mode | Action |
|-----|------|--------|
| `jk` | i | Escape to Normal mode |
| `;` | n | Enter Command mode (faster than `:`) |
| `<S-Tab>` | n | Switch to previous buffer |
| `<Space>` | n | Leader key (wait for which-key) |
| `<leader>z` | n | Toggle focus mode (centerpad) |
| `Ctrl+h` | i | Delete word backward |

### LSP / IDE

| Key | Mode | Action |
|-----|------|--------|
| `K` | n | Hover documentation |
| `gi` | n | Go to implementation |
| `gd` | n | Go to definition |
| `F12` | n | Go to definition |
| `gr` | n | Go to references |
| `<leader>ra` | n | Rename symbol |
| `<leader>ca` | n, v | Code actions |
| `Ctrl+k` | n | Signature help |

### Debugging

| Key | Mode | Action |
|-----|------|--------|
| `F5` | n | Start/Continue debugging |
| `F9` | n | Toggle breakpoint |
| `F10` | n | Step over |
| `F11` | n | Step into |
| `F8` | n | Step out |
| `F6` | n | Debug nearest test |
| `<leader>du` | n | Toggle debug UI |
| `<leader>dr` | n | Open REPL |
| `<leader>dl` | n | Run last debug config |
| `<leader>dt` | n | Debug nearest test |
| `Q` | n, v | Peek variable value |
| `<leader>dw` | n, v | Add to watches |

### Comments

| Key | Mode | Action |
|-----|------|--------|
| `gcc` | n | Toggle line comment |
| `gbc` | n | Toggle block comment |
| `gc` | v | Comment selection |
| `<C-k>c` | n | Toggle comment (VS style) |
| `<C-k><C-c>` | n | Toggle comment (VS style) |

### File/Search (LazyVim defaults)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>e` | n | Toggle file explorer |
| `<leader>ff` | n | Find files |
| `<leader>fg` | n | Live grep |
| `<leader>fb` | n | Find buffers |
| `<leader>fr` | n | Recent files |
| `<leader>sg` | n | Search grep |

---

## Part 6: Visual Studio/Rider Comparison

### Navigation

| VS/Rider | Neovim | Notes |
|----------|--------|-------|
| `F12` Go to Definition | `F12` or `gd` | Same! |
| `Ctrl+F12` Go to Implementation | `gi` | |
| `Shift+F12` Find References | `gr` | |
| `Ctrl+T` Go to Symbol | `<leader>ss` | Telescope symbols |
| `Ctrl+Shift+T` Go to File | `<leader>ff` | Telescope files |
| `Ctrl+G` Go to Line | `:{number}` or `{number}G` | |
| `Ctrl+-` Navigate Back | `Ctrl+o` | Jump list |
| `Ctrl+Shift+-` Navigate Forward | `Ctrl+i` | Jump list |

### Editing

| VS/Rider | Neovim | Notes |
|----------|--------|-------|
| `Ctrl+C` / `Ctrl+V` | `yy` / `p` | Yank line / paste |
| `Ctrl+X` (cut line) | `dd` | Delete line (goes to register) |
| `Ctrl+D` Duplicate Line | `yyp` | Yank + paste |
| `Ctrl+Shift+K` Delete Line | `dd` | |
| `Alt+Up/Down` Move Line | `:m +1` / `:m -2` | Or use mini.move plugin |
| `Ctrl+/` Toggle Comment | `gcc` | Single line |
| `Ctrl+K,C` Comment | `<C-k>c` | Same binding! |
| `Ctrl+Z` Undo | `u` | |
| `Ctrl+Y` Redo | `Ctrl+r` | |

### Refactoring

| VS/Rider | Neovim | Notes |
|----------|--------|-------|
| `F2` Rename | `<leader>ra` | LSP rename |
| `Ctrl+.` Quick Actions | `<leader>ca` | Code actions |
| `Ctrl+Shift+R` Refactor Menu | `<leader>ca` | Same (code actions) |

### Search

| VS/Rider | Neovim | Notes |
|----------|--------|-------|
| `Ctrl+F` Find | `/` | Then `n`/`N` for next/prev |
| `Ctrl+H` Replace | `:%s/old/new/g` | |
| `Ctrl+Shift+F` Find in Files | `<leader>sg` | Telescope grep |
| `Ctrl+Shift+H` Replace in Files | `:cdo s/old/new/g` | After grep |

### Debugging

| VS/Rider | Neovim | Notes |
|----------|--------|-------|
| `F5` Start Debugging | `F5` | Same! |
| `F5` Continue | `F5` | Same! |
| `F9` Toggle Breakpoint | `F9` | Same! |
| `F10` Step Over | `F10` | Same! |
| `F11` Step Into | `F11` | Same! |
| `Shift+F11` Step Out | `F8` | Different key |
| Hover for value | `Q` | Quick peek |

### View/Windows

| VS/Rider | Neovim | Notes |
|----------|--------|-------|
| Solution Explorer | `<leader>e` | Neo-tree |
| `Ctrl+Tab` Switch Document | `<S-Tab>` | Previous buffer |
| Split Editor | `Ctrl+w v` | Vertical split |
| Close Tab | `:bd` or `<leader>bd` | Close buffer |

---

## Tips for VS/Rider Users

### 1. Embrace Normal Mode

The biggest mental shift: **you're not always in typing mode**. In vim, you're usually in Normal mode, navigating and commanding. Insert mode is just for typing text.

### 2. Use the Leader Key

When you don't know a command, press `<Space>` and wait. Which-key will show you options. This is your discoverability tool.

### 3. Think in Motions

Instead of selecting text with mouse/shift+arrows, think in terms of:
- "Delete word" = `dw`
- "Change inside quotes" = `ci"`
- "Yank paragraph" = `yap`

### 4. Learn Incrementally

Don't try to learn everything at once. Start with:
1. `hjkl` movement
2. `i` and `Esc`/`jk` to enter/exit Insert mode
3. `dd`, `yy`, `p` for cut/copy/paste lines
4. `:w` to save, `:q` to quit

Then gradually add:
5. Word motions: `w`, `b`, `e`
6. Text objects: `ciw`, `ci"`, `ci{`
7. Search: `/`, `n`, `N`
8. Leader commands: `<Space>...`

### 5. Use the Mouse (Initially)

Neovim supports mouse! While learning, it's okay to click and scroll. Gradually transition to keyboard-only as you get comfortable.

### 6. The Dot Command is Magic

Press `.` to repeat your last change. Made an edit? Navigate somewhere else and press `.` to do the same thing.

### 7. Buffers, Not Tabs

Think of buffers as your open files. Use `<S-Tab>` to quickly switch between your two most recent files. Use `<leader>fb` to see all open buffers.

---

## Getting Help

### Built-in Help

| Command | What It Shows |
|---------|---------------|
| `:help {topic}` | Help for any topic |
| `:help motion` | All motion commands |
| `:help text-objects` | All text objects |
| `:help keycodes` | Special key names |
| `K` (on vim help) | Jump to help tag |

### This Configuration

| Command | What It Shows |
|---------|---------------|
| `:Lazy` | Plugin manager |
| `:Mason` | LSP/tool installer |
| `:checkhealth` | Diagnose issues |
| `:LspInfo` | LSP status |

### Learning Resources

1. **vimtutor** - Run `vimtutor` in terminal for interactive tutorial
2. **:help user-manual** - Built-in comprehensive manual
3. **Which-key** - Press any prefix key and wait

---

## Quick Start Checklist

- [ ] Open a C# file and verify LSP starts (check `:LspInfo`)
- [ ] Try `K` on a symbol to see hover docs
- [ ] Use `F12` to go to definition, `Ctrl+o` to go back
- [ ] Press `<Space>` and wait - explore the leader menu
- [ ] Try `<leader>ff` to fuzzy-find files
- [ ] Set a breakpoint with `F9`, start debugging with `F5`
- [ ] Use `gcc` to comment a line
- [ ] Use `ci"` to change text inside quotes
- [ ] Use `<S-Tab>` to switch between two buffers

Welcome to Neovim!
