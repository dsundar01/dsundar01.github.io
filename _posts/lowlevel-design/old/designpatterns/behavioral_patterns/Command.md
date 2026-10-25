# Command Pattern

## CAUSE and EFFECT

```
CAUSE (the technique):
"Encapsulate a request/action as an object so it can be passed,
stored, queued, logged, or undone independently of the caller"

EFFECT (the benefit):
"Decouples the invoker (who triggers the action) from the receiver
(who performs the action), enabling undo, redo, queuing, and logging"
```

## The Problem in Normal Code

Suppose you build a **text editor** with toolbar buttons.

```java
class TextEditor {
    private StringBuilder content = new StringBuilder();

    void bold() {
        content.append("<b>");
        System.out.println("Bold applied");
    }

    void italic() {
        content.append("<i>");
        System.out.println("Italic applied");
    }

    void copy() {
        System.out.println("Copied to clipboard");
    }

    void paste(String text) {
        content.append(text);
        System.out.println("Pasted: " + text);
    }
}
```

Toolbar buttons directly call the editor:

```java
class Toolbar {
    private TextEditor editor;

    Toolbar(TextEditor editor) {
        this.editor = editor;
    }

    void onBoldClick() {
        editor.bold();
    }

    void onItalicClick() {
        editor.italic();
    }

    void onCopyClick() {
        editor.copy();
    }

    void onPasteClick(String text) {
        editor.paste(text);
    }

    void onUndoClick() {
        // ??? How do we know what the last action was?
        // ??? How do we reverse it?
        // IMPOSSIBLE without tracking history
    }
}
```

**What goes wrong:**

- Toolbar is tightly coupled to TextEditor — it calls specific methods directly
- **Undo is impossible** — there's no record of what happened
- **Redo is impossible** — once undone, the action is lost
- **Macro/replay is impossible** — can't store a sequence of actions
- **Logging/audit is impossible** — actions aren't objects, they're direct calls
- Adding a new button means changing the Toolbar class
- Keyboard shortcut, menu item, and toolbar button for the same action → duplicate code
- Can't queue actions for batch execution

## The Key Insight

Instead of directly calling a method, **wrap each action as an object**. The object knows:
- WHAT to do (execute)
- HOW to undo it (undo)
- WHO performs it (receiver)

```
Without Command:
Button ──directly calls──> editor.bold()
                           (action is gone, no history, no undo)

With Command:
Button ──calls──> BoldCommand.execute() ──calls──> editor.bold()
                  |
                  stored in history stack
                  can be undone, replayed, logged
```

## Three Approaches

**AP1:** Invoker directly calls receiver methods — tight coupling, no undo, no history.

**AP2:** Store action names as strings and use if/else to replay — fragile, no type safety, undo still hard.

**AP3:** Use Command pattern — each action is an object with execute() and undo(). Invoker stores command objects in a history stack. Undo/redo/macro/logging all become trivial.

## The Pattern Structure

```
Invoker (Toolbar/Button)
  |
  | triggers
  v
Command (interface)
  execute()
  undo()
      |
  _________________________
  |          |            |
BoldCommand  ItalicCommand  PasteCommand
  |               |              |
  | calls         | calls        | calls
  v               v              v
Receiver (TextEditor)
```

Key participants:

Term | What it is | Example
-- | -- | --
Command | Interface with execute() and undo() | Command interface
Concrete Command | Specific action wrapped as object | BoldCommand, PasteCommand
Invoker | Triggers commands, stores history | Toolbar, Button, RemoteControl
Receiver | The actual object that performs the work | TextEditor
Client | Creates commands and wires everything together | Application setup code

## Implementation

### Step 1: Command interface

```java
interface Command {
    void execute();
    void undo();
}
```

### Step 2: Receiver — the object that does the real work

```java
class TextEditor {
    private StringBuilder content = new StringBuilder();

    void addText(String text) {
        content.append(text);
    }

    void removeText(int length) {
        int start = content.length() - length;
        if (start >= 0) {
            content.delete(start, content.length());
        }
    }

    void boldOn() { content.append("<b>"); }
    void boldOff() { content.append("</b>"); }

    void italicOn() { content.append("<i>"); }
    void italicOff() { content.append("</i>"); }

    String getContent() { return content.toString(); }
}
```

### Step 3: Concrete commands — each wraps one action

**BoldCommand:**

```java
class BoldCommand implements Command {
    private TextEditor editor;

    BoldCommand(TextEditor editor) {
        this.editor = editor;
    }

    public void execute() {
        editor.boldOn();
        System.out.println("Bold applied");
    }

    public void undo() {
        editor.removeText(3);  // remove "<b>"
        System.out.println("Bold undone");
    }
}
```

**PasteCommand:**

```java
class PasteCommand implements Command {
    private TextEditor editor;
    private String text;

    PasteCommand(TextEditor editor, String text) {
        this.editor = editor;
        this.text = text;
    }

    public void execute() {
        editor.addText(text);
        System.out.println("Pasted: " + text);
    }

    public void undo() {
        editor.removeText(text.length());
        System.out.println("Paste undone: " + text);
    }
}
```

**ItalicCommand:**

```java
class ItalicCommand implements Command {
    private TextEditor editor;

    ItalicCommand(TextEditor editor) {
        this.editor = editor;
    }

    public void execute() {
        editor.italicOn();
        System.out.println("Italic applied");
    }

    public void undo() {
        editor.removeText(3);  // remove "<i>"
        System.out.println("Italic undone");
    }
}
```

### Step 4: Invoker — triggers commands and manages history

```java
class EditorInvoker {
    private Stack<Command> undoStack = new Stack<>();
    private Stack<Command> redoStack = new Stack<>();

    void executeCommand(Command command) {
        command.execute();
        undoStack.push(command);
        redoStack.clear();  // new action clears redo history
    }

    void undo() {
        if (!undoStack.isEmpty()) {
            Command command = undoStack.pop();
            command.undo();
            redoStack.push(command);
        } else {
            System.out.println("Nothing to undo");
        }
    }

    void redo() {
        if (!redoStack.isEmpty()) {
            Command command = redoStack.pop();
            command.execute();
            undoStack.push(command);
        } else {
            System.out.println("Nothing to redo");
        }
    }
}
```

### Step 5: Client code

```java
TextEditor editor = new TextEditor();
EditorInvoker invoker = new EditorInvoker();

// Execute commands
invoker.executeCommand(new PasteCommand(editor, "Hello "));   // "Pasted: Hello "
invoker.executeCommand(new BoldCommand(editor));                // "Bold applied"
invoker.executeCommand(new PasteCommand(editor, "World"));     // "Pasted: World"

System.out.println(editor.getContent());  // "Hello <b>World"

// Undo last action
invoker.undo();  // "Paste undone: World"
System.out.println(editor.getContent());  // "Hello <b>"

// Undo again
invoker.undo();  // "Bold undone"
System.out.println(editor.getContent());  // "Hello "

// Redo
invoker.redo();  // "Bold applied"
System.out.println(editor.getContent());  // "Hello <b>"
```

## Before vs After

**Before (without Command):**

```java
// Button directly calls editor
button.onClick(() -> editor.bold());
// No history, no undo, no redo, no logging
// Undo is IMPOSSIBLE without rewriting everything
```

**After (with Command):**

```java
// Button triggers a command object
button.onClick(() -> invoker.executeCommand(new BoldCommand(editor)));
// History tracked, undo/redo free, logging trivial, macros possible
```

## Bonus: Macro Command (Composite + Command)

A macro is a command that contains a list of other commands:

```java
class MacroCommand implements Command {
    private List<Command> commands = new ArrayList<>();

    void addCommand(Command command) {
        commands.add(command);
    }

    public void execute() {
        for (Command c : commands) {
            c.execute();
        }
    }

    public void undo() {
        // Undo in reverse order
        for (int i = commands.size() - 1; i >= 0; i--) {
            commands.get(i).undo();
        }
    }
}
```

```java
MacroCommand formatMacro = new MacroCommand();
formatMacro.addCommand(new BoldCommand(editor));
formatMacro.addCommand(new ItalicCommand(editor));
formatMacro.addCommand(new PasteCommand(editor, "Title"));

// Execute all three at once
invoker.executeCommand(formatMacro);

// Undo all three at once
invoker.undo();
```

## What Command Enables

Feature | How Command makes it possible
-- | --
Undo | Call command.undo() from the history stack
Redo | Re-call command.execute() from the redo stack
Macro | List of commands executed as one
Logging | Store command objects with timestamps
Queuing | Put commands in a queue, execute later
Transaction | Execute all or undo all if one fails
Replay | Re-execute stored command sequence
Deferred execution | Create command now, execute later

## Real Examples

Example | Command | Invoker | Receiver
-- | -- | -- | --
Text editor | BoldCommand, PasteCommand | Toolbar/Keyboard | TextEditor
Remote control | TurnOnCommand, VolumeUpCommand | RemoteControl | TV, Light, Fan
Restaurant | Order (the slip) | Waiter | Chef
Task scheduler | ScheduledTask | Scheduler | Worker service
Transaction | TransferCommand | TransactionManager | BankAccount
Game | MoveCommand, AttackCommand | InputHandler | Character

**Restaurant analogy (best for interviews):**

```
Customer → tells → Waiter → writes Order slip → gives to → Chef

Customer = Client (creates the command)
Waiter = Invoker (carries and triggers the command)
Order slip = Command (the request as an object)
Chef = Receiver (does the actual work)

The waiter doesn't cook. The customer doesn't go to the kitchen.
The order slip decouples them.
```

**Java/JDK usage:**

- `Runnable` — a command with only execute() (called `run()`):
```java
Runnable command = () -> System.out.println("Do something");
// Pass it around, queue it, execute later
executor.submit(command);  // invoker executes it
```

- `Callable<T>` — a command that returns a result
- `javax.swing.Action` — Swing's command abstraction for buttons, menus, keyboard shortcuts
- `java.util.concurrent.ExecutorService` — invoker that queues and executes Runnable/Callable commands
- `CompletableFuture` — wraps computation as a command for async execution

```java
// Same command reused for button, menu, and keyboard shortcut
Action saveAction = new SaveAction(editor);
toolbar.add(saveAction);          // toolbar button
menu.add(saveAction);             // menu item
inputMap.put(ctrlS, saveAction);  // keyboard shortcut
// All three trigger the same command object
```

## Where Is the Command?

```java
class BoldCommand implements Command {
    private TextEditor editor;  // <-- reference to receiver

    public void execute() {
        editor.boldOn();  // delegate to receiver
    }

    public void undo() {
        editor.removeText(3);  // reverse the action
    }
}
```

The command:
1. Implements the Command interface
2. Holds a reference to the RECEIVER (who does the work)
3. Knows HOW to execute the action
4. Knows HOW to undo the action
5. Is stored by the INVOKER for history/undo/redo

## Design Principles

Principle | How Command uses it
-- | --
Single Responsibility | Each command handles one specific action
Open/Closed | Add new commands without modifying invoker or receiver
Separation of Concerns | Invoker handles triggering/history. Command handles action. Receiver handles domain work.
Program to interface | Invoker depends on Command interface, not concrete commands
Encapsulation | Action details are encapsulated inside the command object

## Comparison with Other Patterns

### Command vs Strategy

```
STRUCTURALLY: Both encapsulate behavior in an object

INTENT:
Command: encapsulates a REQUEST with full context (receiver, params, undo)
         Purpose: store, queue, undo, log actions
Strategy: encapsulates an ALGORITHM that the caller uses
          Purpose: swap behavior at runtime

Command: usually has undo(), stored in history
Strategy: no undo concept, no history, just used and discarded

Command: "do this specific thing later and maybe undo it"
Strategy: "use this approach to solve the problem"
```

### Command vs State

```
State: object changes behavior based on INTERNAL state
       States know about each other and transition automatically
Command: object wraps a SINGLE action as an independent request
         Commands don't know about each other

State: "I behave differently now because my state changed"
Command: "Here is an action, execute it whenever you want"
```

### Command vs Observer

```
Command: one invoker triggers ONE specific command
Observer: one event notifies MANY observers

Command: direct, targeted action
Observer: broadcast notification

They can work together:
Event (Observer) triggers → Command.execute()
```

### Command vs Memento

```
Command: records ACTIONS (what happened) and can undo them
Memento: records STATE (snapshot) and can restore it

Command undo: reverses the action (e.g., delete the pasted text)
Memento undo: restores entire previous state (e.g., full content snapshot)

Command: more granular, action-level
Memento: more coarse, snapshot-level
```

```
COMMAND UNDO:
Step 1: Paste "Hello"     → undo removes "Hello"
Step 2: Bold              → undo removes "<b>"
(reverses individual actions)

MEMENTO UNDO:
Step 1: Save snapshot: ""
Step 2: Paste "Hello"
Step 3: Save snapshot: "Hello"
Step 4: Bold
Step 5: Save snapshot: "Hello<b>"
Undo → restore snapshot: "Hello"
(restores entire state)
```

### Command vs Proxy

```
Proxy: controls ACCESS to a real object (same interface)
Command: wraps a REQUEST as an object (different concept)

Proxy: stands in for the real object
Command: stands in for the real action
```

## The Progression Story (for interviews)

Step | What happens | Problem
-- | -- | --
1 | Button directly calls editor.bold() | Works but tightly coupled
2 | User wants Undo | No history of actions — impossible
3 | User wants Redo, Macro, Logging | Direct calls don't support any of these
4 | Use Command: wrap each action as an object with execute() and undo() | Invoker stores commands in stack. Undo/redo/macro/logging all become trivial.

## How to Identify When to Use Command

Checklist:
- Need to decouple who triggers an action from who performs it? Yes
- Need undo/redo? Yes
- Need to queue, schedule, or log actions? Yes
- Need macros (sequence of actions as one)? Yes
- Same action triggered from multiple places (button, menu, shortcut)? Yes

If any of these are yes → Command pattern is a good fit.

## Quick Reference

Question | Answer
-- | --
What problem does it solve? | Decouples invoker from receiver; enables undo, redo, queuing, logging, and macros
What is the command? | An object that encapsulates an action with execute() and undo()
What is the invoker? | The trigger that calls execute() and manages history (Toolbar, Button, Scheduler)
What is the receiver? | The object that does the actual work (TextEditor, TV, BankAccount)
How does undo work? | Invoker pops last command from history stack and calls command.undo()
How does redo work? | Invoker pops from redo stack and calls command.execute() again
How does macro work? | A composite command that holds a list of other commands
Key rule | Actions become objects. Objects can be stored, passed, undone, replayed.
How is it different from Strategy? | Command = storable request with undo. Strategy = swappable algorithm without history.
How is it different from Memento? | Command undoes by reversing actions. Memento undoes by restoring state snapshots.
Java example | Runnable, Swing Action, ExecutorService
Interview one-liner | Command pattern wraps each action as an object with execute() and undo(), decoupling invoker from receiver and enabling undo, redo, queuing, macros, and logging.
