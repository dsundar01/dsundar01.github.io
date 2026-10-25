# Memento Pattern

## CAUSE and EFFECT

```
CAUSE (the technique):
"Capture an object's internal state as a snapshot object (memento)
so it can be restored later, without exposing the object's internals"

EFFECT (the benefit):
"Enables undo/restore functionality while preserving encapsulation —
no other object needs to know the internal structure of the saved state"
```

## The Problem in Normal Code

Suppose you build a **text editor** that needs undo.

```java
class TextEditor {
    private String content;
    private int cursorPosition;
    private String font;
    private int fontSize;

    void type(String text) {
        content += text;
        cursorPosition += text.length();
    }

    void setFont(String font, int size) {
        this.font = font;
        this.fontSize = size;
    }

    // To support undo, expose everything?
    String getContent() { return content; }
    int getCursorPosition() { return cursorPosition; }
    String getFont() { return font; }
    int getFontSize() { return fontSize; }

    void setContent(String content) { this.content = content; }
    void setCursorPosition(int pos) { this.cursorPosition = pos; }
    // ... expose ALL internal fields with getters AND setters
}
```

Now the undo manager must know every field:

```java
class UndoManager {
    // Must store EVERY field manually
    private String savedContent;
    private int savedCursor;
    private String savedFont;
    private int savedFontSize;

    void save(TextEditor editor) {
        savedContent = editor.getContent();
        savedCursor = editor.getCursorPosition();
        savedFont = editor.getFont();
        savedFontSize = editor.getFontSize();
    }

    void restore(TextEditor editor) {
        editor.setContent(savedContent);
        editor.setCursorPosition(savedCursor);
        editor.setFont(savedFont, savedFontSize);
    }
}
```

**What goes wrong:**

- TextEditor must expose ALL internal fields with public getters AND setters — **breaks encapsulation**
- UndoManager knows every detail of TextEditor's internal structure — **tight coupling**
- If you add a new field to TextEditor (e.g., `selectionStart`), you must also update UndoManager — **fragile**
- Multiple undo levels means storing multiple copies of every field manually
- Every class that needs saving has a different structure → UndoManager can't be reused
- Other code can misuse the exposed setters to corrupt the editor state

## The Key Insight

The object itself should create a snapshot of its own state and the object itself should restore from that snapshot. Nobody else needs to know what is inside the snapshot.

```
Without Memento:
UndoManager ──reads all fields──> TextEditor (encapsulation broken)
UndoManager ──writes all fields──> TextEditor

With Memento:
TextEditor ──creates──> Memento (snapshot)     ← editor packages its own state
UndoManager ──stores──> Memento                ← manager just holds the opaque box
TextEditor ──restores from──> Memento          ← editor unpacks its own state
                                UndoManager never looks inside the Memento
```

## Three Approaches

**AP1:** Expose all fields with getters/setters so external code can save/restore — breaks encapsulation, tight coupling, fragile.

**AP2:** Serialize the entire object to string/JSON — heavy, slow, overkill for simple undo.

**AP3:** Use Memento pattern — the object creates its own opaque snapshot. The caretaker stores it. The object restores from it. Encapsulation preserved.

## The Pattern Structure

```
Originator (TextEditor)
  |
  | creates / restores from
  v
Memento (EditorSnapshot)
  |                          ← opaque to everyone except Originator
  | stored by
  v
Caretaker (UndoManager)
  |
  | holds a stack of mementos
  | never looks inside them
```

Key participants:

Term | What it is | Example
-- | -- | --
Originator | The object whose state needs to be saved/restored | TextEditor
Memento | The snapshot object that holds the saved state | EditorSnapshot
Caretaker | Manages mementos (stores, retrieves) but never inspects them | UndoManager, History

## Implementation

### Step 1: Memento — holds the snapshot (ideally immutable, opaque)

```java
class EditorMemento {
    private final String content;
    private final int cursorPosition;
    private final String font;
    private final int fontSize;

    // Package-private or inner class — only Originator should access
    EditorMemento(String content, int cursorPosition, String font, int fontSize) {
        this.content = content;
        this.cursorPosition = cursorPosition;
        this.font = font;
        this.fontSize = fontSize;
    }

    String getContent() { return content; }
    int getCursorPosition() { return cursorPosition; }
    String getFont() { return font; }
    int getFontSize() { return fontSize; }
}
```

### Step 2: Originator — creates and restores from memento

```java
class TextEditor {
    private String content = "";
    private int cursorPosition = 0;
    private String font = "Arial";
    private int fontSize = 12;

    void type(String text) {
        content += text;
        cursorPosition += text.length();
        System.out.println("Typed: " + text + " | Content: " + content);
    }

    void setFont(String font, int size) {
        this.font = font;
        this.fontSize = size;
        System.out.println("Font: " + font + " " + size);
    }

    // CREATE snapshot — only the editor knows what to save
    EditorMemento save() {
        return new EditorMemento(content, cursorPosition, font, fontSize);
    }

    // RESTORE from snapshot — only the editor knows how to unpack
    void restore(EditorMemento memento) {
        this.content = memento.getContent();
        this.cursorPosition = memento.getCursorPosition();
        this.font = memento.getFont();
        this.fontSize = memento.getFontSize();
        System.out.println("Restored | Content: " + content);
    }

    String getContent() { return content; }
}
```

### Step 3: Caretaker — stores mementos, never looks inside

```java
class UndoManager {
    private Stack<EditorMemento> undoStack = new Stack<>();
    private Stack<EditorMemento> redoStack = new Stack<>();

    void save(EditorMemento memento) {
        undoStack.push(memento);
        redoStack.clear();
    }

    EditorMemento undo() {
        if (undoStack.isEmpty()) {
            System.out.println("Nothing to undo");
            return null;
        }
        EditorMemento memento = undoStack.pop();
        redoStack.push(memento);
        return undoStack.isEmpty() ? null : undoStack.peek();
    }

    EditorMemento redo() {
        if (redoStack.isEmpty()) {
            System.out.println("Nothing to redo");
            return null;
        }
        EditorMemento memento = redoStack.pop();
        undoStack.push(memento);
        return memento;
    }
}
```

### Step 4: Client code

```java
TextEditor editor = new TextEditor();
UndoManager history = new UndoManager();

// Save initial state
history.save(editor.save());

// Type something
editor.type("Hello ");          // Content: "Hello "
history.save(editor.save());

editor.type("World");           // Content: "Hello World"
history.save(editor.save());

editor.setFont("Consolas", 14); // Font changed
history.save(editor.save());

// Now undo
System.out.println("--- UNDO ---");
EditorMemento m = history.undo();
if (m != null) editor.restore(m);  // Restored: "Hello World" (font change undone)

m = history.undo();
if (m != null) editor.restore(m);  // Restored: "Hello " (World undone)

m = history.undo();
if (m != null) editor.restore(m);  // Restored: "" (Hello undone)

// Now redo
System.out.println("--- REDO ---");
m = history.redo();
if (m != null) editor.restore(m);  // Restored: "Hello "
```

## Before vs After

**Before (without Memento):**

```java
// UndoManager must know every field
class UndoManager {
    String savedContent;
    int savedCursor;
    String savedFont;
    int savedFontSize;
    // Add a new field to editor? Must update here too.
    // Encapsulation broken. Tight coupling.
}
```

**After (with Memento):**

```java
// UndoManager knows NOTHING about editor internals
class UndoManager {
    Stack<EditorMemento> undoStack;
    // Just stores opaque memento objects
    // Editor adds a new field? UndoManager is UNCHANGED.
}
```

## The Encapsulation Rule

```
WHO can create a memento?      ONLY the Originator (TextEditor)
WHO can restore from memento?  ONLY the Originator (TextEditor)
WHO stores the memento?        The Caretaker (UndoManager)
WHO looks inside the memento?  NOBODY except the Originator

The Caretaker treats the memento as a black box.
```

In Java, you can enforce this by making Memento an **inner class** of the Originator:

```java
class TextEditor {
    private String content;

    // Inner class — only TextEditor can access its fields
    class Memento {
        private final String savedContent;
        private Memento(String content) { this.savedContent = content; }
    }

    Memento save() { return new Memento(content); }
    void restore(Memento m) { this.content = m.savedContent; }
}
```

Now the UndoManager can hold `TextEditor.Memento` objects but cannot access `savedContent`.

## Memory Concern

Each memento is a full snapshot. With many undos, memory grows.

Snapshots | Content size | Memory used
-- | -- | --
10 | 1 KB | 10 KB
100 | 10 KB | 1 MB
1000 | 100 KB | 100 MB

**Solutions:**

Strategy | How it works
-- | --
Limit history size | Keep only last N mementos, discard oldest
Incremental mementos | Store only the DIFF (change), not full state
Compress snapshots | Compress memento data
Combine with Command | Use Command for fine-grained undo, Memento for checkpoints

## Real Examples

Example | Originator | Memento | Caretaker
-- | -- | -- | --
Text editor undo | TextEditor | EditorSnapshot | UndoManager
Game save/load | GameState | SaveFile | SaveManager
Database transaction | DatabaseConnection | Savepoint | TransactionManager
Form draft | FormData | DraftSnapshot | AutoSaveManager
Browser back button | WebPage | PageState | BrowserHistory
Drawing app | Canvas | CanvasSnapshot | HistoryPanel
Config rollback | AppConfig | ConfigSnapshot | ConfigManager

**Java/JDK usage:**

- `java.sql.Connection.setSavepoint()` — database savepoint is a Memento:
```java
Connection conn = dataSource.getConnection();
Savepoint sp = conn.setSavepoint("beforeUpdate");  // create memento

try {
    // execute SQL statements
    conn.commit();
} catch (Exception e) {
    conn.rollback(sp);  // restore from memento
}
```

- `java.io.Serializable` — serialization can serve as a Memento mechanism (full state snapshot to bytes)
- `java.util.Date` — `clone()` for defensive copies is a simple Memento idea
- IDE undo history — every Ctrl+Z in IntelliJ/VS Code is Memento at work

## Design Principles

Principle | How Memento uses it
-- | --
Encapsulation | Internal state is saved/restored without exposing it to other objects
Single Responsibility | Originator handles its own state. Caretaker handles storage. Memento holds the snapshot.
Separation of Concerns | State management separated from state storage
Information Hiding | Caretaker never knows what is inside the memento

## Comparison with Other Patterns

### Memento vs Command

```
BOTH support undo, but differently:

Command undo: reverses the ACTION (knows how to undo what it did)
Memento undo: restores the STATE (reverts to a previous snapshot)

Command: lightweight — stores the action + params
Memento: heavier — stores the entire state snapshot

Command: precise undo for each action
Memento: broad undo — restores everything to a previous point
```

```
COMMAND UNDO:
Action: Paste "Hello"
Undo: remove last 5 characters
(reverses the specific action)

MEMENTO UNDO:
State before: ""
State after:  "Hello"
Undo: restore entire state to ""
(restores the full snapshot)
```

```
When to use which:
- Actions are easily reversible → Command
- State is complex, actions are hard to reverse → Memento
- Best practice: use BOTH together
  Command for fine-grained action undo
  Memento for periodic full-state checkpoints
```

### Memento vs Prototype

```
Prototype: copies an object to CREATE a new independent object
Memento: copies an object's state to RESTORE it later

Prototype: "I want another object like this one"
Memento: "I want THIS object to go back to how it was"

Prototype: clone creates a NEW object
Memento: restore modifies the EXISTING object
```

### Memento vs State

```
State: current behavior changes based on current state
       (each state is a different class with different behavior)
Memento: saves and restores previous state
         (snapshot of internal data, not behavior)

State pattern: "I behave differently now"
Memento pattern: "I want to go back to how I was before"
```

### Memento vs Flyweight

```
Flyweight: SHARES state to save memory
Memento: COPIES state to enable undo

Flyweight: "Don't duplicate, share"
Memento: "Duplicate, so we can go back"

Opposite concerns. Flyweight minimizes copies. Memento maximizes copies.
```

### Memento vs Proxy

```
Proxy: controls ACCESS to an object
Memento: captures STATE of an object

No structural similarity. Different problems entirely.
```

## The Progression Story (for interviews)

Step | What happens | Problem
-- | -- | --
1 | Editor works without undo | Users want undo
2 | Expose all fields with getters/setters so external code can save | Encapsulation broken, tight coupling
3 | Add a new field to editor | Must update every place that saves/restores — fragile
4 | Use Memento: editor creates its own opaque snapshot, caretaker just stores it | Encapsulation preserved. Add new fields? Only editor.save() and editor.restore() change. Caretaker is untouched.

## How to Identify When to Use Memento

Checklist:
- Need to save and restore an object's state? Yes
- Object's internal structure should NOT be exposed? Yes
- Multiple undo levels needed? Yes
- State is too complex to reverse action-by-action? Yes

If yes → Memento is a good fit.

## Quick Reference

Question | Answer
-- | --
What problem does it solve? | Save and restore an object's state without breaking encapsulation
What is the Originator? | The object whose state needs saving (TextEditor)
What is the Memento? | The opaque snapshot object that holds the saved state (EditorSnapshot)
What is the Caretaker? | The object that stores mementos but never looks inside (UndoManager)
Who creates the memento? | Only the Originator
Who restores from the memento? | Only the Originator
Who stores the memento? | The Caretaker
Can the Caretaker look inside? | No. The memento is a black box to the Caretaker.
How is it different from Command? | Command undoes by reversing actions. Memento undoes by restoring full state snapshots.
How is it different from Prototype? | Prototype clones to create new objects. Memento snapshots to restore existing objects.
Memory concern? | Each memento is a full snapshot. Limit history size or use incremental diffs.
Java example | java.sql.Connection.setSavepoint(), IDE undo history
Interview one-liner | Memento pattern captures an object's internal state as an opaque snapshot so it can be restored later, enabling undo without breaking encapsulation — the originator creates and restores mementos, the caretaker stores them without looking inside.
