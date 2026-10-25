
# Composite Pattern

## CAUSE and EFFECT

CAUSE (the technique):
"Treat individual objects and compositions of objects uniformly through a shared interface"

EFFECT (the benefit):
"Eliminates type-checking and special-case branching when working with tree/part-whole structures"

## The Problem in Normal Code

Suppose you build a file system viewer that calculates total size.

```java
class File {
    String name;
    int size;
    int getSize() { return size; }
}

class Folder {
    String name;
    List<File> files;
    List<Folder> subFolders;

    int getSize() {
        int total = 0;
        for (File f : files) total += f.getSize();
        for (Folder f : subFolders) total += f.getSize();
        return total;
    }
}
```

Client code must always know whether it is dealing with a File or Folder:

```java
void printSize(Object item) {
    if (item instanceof File) {
        System.out.println(((File) item).getSize());
    } else if (item instanceof Folder) {
        System.out.println(((Folder) item).getSize());
    }
}
```

What goes wrong as the system grows:
- Add Shortcut? → new if branch everywhere
- Add ZipArchive? → another if branch everywhere
- Every method that works on the file system must check types
- Client code becomes full of instanceof checks
- Folder must maintain separate lists for each type

## Three Approaches

AP1: Use instanceof / if-else to handle each type differently — scattered type-checking everywhere.

AP2: Use a common interface but keep separate lists in containers — still requires special handling for leaf vs container.

AP3: Use Composite pattern — treat leaf and container through one uniform interface. Client never checks types.

## The Pattern Structure

```
          FileSystemItem (interface)
          getName()
          getSize()
              |
     ___________________
     |                 |
   File (leaf)      Folder (composite)
   getSize()        getSize() ← loops over children
                    add(FileSystemItem)
                    remove(FileSystemItem)
                    children: List<FileSystemItem>  ← holds BOTH files AND folders
```

Key insight: Folder holds a list of FileSystemItem, not separate lists for File and Folder. It does not know or care what is inside it.

## Implementation

### Step 1: Common interface

```java
interface FileSystemItem {
    String getName();
    int getSize();
}
```

### Step 2: Leaf (no children)

```java
class File implements FileSystemItem {
    private String name;
    private int size;

    File(String name, int size) {
        this.name = name;
        this.size = size;
    }

    public String getName() { return name; }
    public int getSize() { return size; }
}
```

### Step 3: Composite (has children)

```java
class Folder implements FileSystemItem {
    private String name;
    private List<FileSystemItem> children = new ArrayList<>();

    Folder(String name) { this.name = name; }

    public String getName() { return name; }

    public int getSize() {
        int total = 0;
        for (FileSystemItem child : children) {
            total += child.getSize();  // does not care if child is File or Folder
        }
        return total;
    }

    void add(FileSystemItem item) { children.add(item); }
    void remove(FileSystemItem item) { children.remove(item); }
}
```

### Step 4: Client code — uniform, no type checking

```java
File a = new File("a.txt", 10);
File b = new File("b.txt", 20);
File c = new File("c.txt", 30);

Folder docs = new Folder("docs");
docs.add(a);
docs.add(b);

Folder root = new Folder("root");
root.add(docs);
root.add(c);

// Client does not care what is inside
System.out.println(root.getSize());  // 60
System.out.println(docs.getSize());  // 30
System.out.println(a.getSize());     // 10

// All three calls look IDENTICAL. That is the point.
```

## Before vs After

Before (without Composite):

```java
void printSize(Object item) {
    if (item instanceof File) {
        System.out.println(((File) item).getSize());
    } else if (item instanceof Folder) {
        // manually iterate files AND subfolders separately
    } else if (item instanceof Shortcut) {
        // another branch
    }
}
```

After (with Composite):

```java
void printSize(FileSystemItem item) {
    System.out.println(item.getSize());  // done. works for everything.
}
```

## Where Is the Recursion?

```java
// Folder.getSize()
for (FileSystemItem child : children) {
    total += child.getSize();
    // if child is a File → returns its size directly
    // if child is a Folder → calls getSize() again, which loops its own children
    // this is recursive, but the client never writes the recursion
}
```

The recursion is inside the composite, not in client code. The client just calls getSize() once.

## Key Terminology

- Leaf: Individual object with no children (File)
- Composite: Container that holds children of the same interface type (Folder)
- Component: The shared interface both leaf and composite implement (FileSystemItem)
- The trick: Composite holds a list of Component (interface), not a list of specific types

## Real Examples

| Example | Leaf | Composite | Component |
|---|---|---|---|
| File system | File | Folder | FileSystemItem |
| UI components | Button, Label | Panel, Frame | Component (Swing/AWT) |
| Organization chart | Employee | Department | OrganizationUnit |
| Menu system | MenuItem | Menu (has sub-items) | MenuComponent |
| HTML DOM | TextNode | Element (has child elements) | Node |
| Shopping cart | Product | Bundle/ComboOffer | CartItem |

Java/JDK usage:
- java.awt.Component (leaf) and java.awt.Container (composite) — Container extends Component and holds a list of Components
- Swing: JButton is a leaf, JPanel is a composite, both are JComponent

## Design Principles

| Principle | How Composite uses it |
|---|---|
| Program to interface | Client works with FileSystemItem, not File or Folder |
| Open/Closed | Add new types (ZipArchive) without changing client code |
| Single Responsibility | Each leaf handles its own behavior, composite handles delegation |
| Composition over inheritance | Tree structure built through object composition |

## Comparison with Other Patterns

### Composite vs Iterator

Composite structures the tree. Iterator traverses the tree. They often work together.

### Composite vs Decorator

Both use a common interface and wrap/contain the same type.

- Composite: one container holds MANY children (tree structure) = one-to-many
- Decorator: one wrapper holds ONE wrapped object (chain) = one-to-one

```
COMPOSITE (one-to-many, tree):
Folder
  ├── File
  ├── File
  └── Folder
        ├── File
        └── File

DECORATOR (one-to-one, chain):
BufferedInputStream
  └── FileInputStream
        └── (actual data)
```

### Composite vs Bridge

- Bridge: separates WHAT from HOW (two independent hierarchies)
- Composite: treats ONE and MANY the same (one hierarchy, tree structure)
- Bridge solves: class explosion from multiple dimensions
- Composite solves: type-checking explosion from tree structures

## The Progression Story (for interviews)

| Step | What happens | Approach |
|---|---|---|
| 1 | Only File and Folder exist | Separate classes, manual handling works |
| 2 | Client code has instanceof checks everywhere | Gets messy with each new type |
| 3 | Add Shortcut, ZipArchive, SymLink | Every client method needs more branches |
| 4 | Use Composite: shared interface, container holds interface type | Client code becomes uniform, no type checks |

## Quick Reference

| Question | Answer |
|---|---|
| What problem does it solve? | Eliminates type-checking when working with tree/part-whole structures |
| What is the leaf? | Individual object with no children (File, Button, Employee) |
| What is the composite? | Container that holds children of the same interface type (Folder, Panel, Department) |
| What is the component? | The shared interface both leaf and composite implement |
| Where is the recursion? | Inside the composite's methods, not in client code |
| Key rule | Composite holds a list of Component (interface), not a list of specific types |
| Design principle | Program to interface so client treats leaf and composite identically |
| How is it different from Decorator? | Composite = one-to-many (tree). Decorator = one-to-one (chain). |
| Java example | Component and Container in AWT/Swing |
| Interview one-liner | Composite pattern lets clients treat individual objects and compositions uniformly through a shared interface, eliminating type-checking in tree structures. |


