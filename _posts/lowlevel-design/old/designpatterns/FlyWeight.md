# Flyweight Pattern

## CAUSE and EFFECT

```
CAUSE (the technique):
"Share common (intrinsic) state across many objects instead of
storing it in each object separately"

EFFECT (the benefit):
"Dramatically reduces memory usage when creating large numbers
of similar objects"
```

## The Problem in Normal Code

Suppose you build a **text editor** that renders characters on screen.

```java
class Character {
    char value;          // 'A'
    String font;         // "Arial"
    int fontSize;        // 12
    String color;        // "black"
    boolean bold;        // false
    int row;             // position on screen
    int col;             // position on screen

    void render() {
        System.out.println("Draw " + value + " at (" + row + "," + col + ") "
            + font + " " + fontSize + " " + color);
    }
}
```

A document with 100,000 characters creates 100,000 objects. Each object stores font, fontSize, color, bold — even though most characters share the same formatting.

```java
// 100,000 objects, each storing redundant data
Character c1 = new Character('H', "Arial", 12, "black", false, 0, 0);
Character c2 = new Character('e', "Arial", 12, "black", false, 0, 1);
Character c3 = new Character('l', "Arial", 12, "black", false, 0, 2);
Character c4 = new Character('l', "Arial", 12, "black", false, 0, 3);
Character c5 = new Character('o', "Arial", 12, "black", false, 0, 4);
// ... 99,995 more objects all storing "Arial", 12, "black", false
```

**What goes wrong:**

- 100,000 objects each storing the same font, fontSize, color, bold
- Massive memory waste — maybe 90% of data is duplicated
- Could crash the JVM with OutOfMemoryError on large documents
- Same problem in games (thousands of trees, bullets, particles sharing textures)

## The Key Insight: Intrinsic vs Extrinsic State

Every object's data can be split into two parts:

Type | What it is | Example | Shared?
-- | -- | -- | --
Intrinsic | State that is the SAME across many objects | font, fontSize, color, bold | Yes — share it
Extrinsic | State that is UNIQUE to each object | row, col (position) | No — pass it from outside

The trick: store intrinsic state in a shared object, pass extrinsic state as method parameters.

## Three Approaches

**AP1:** Create one full object per item — simple but wastes massive memory.

**AP2:** Use object pooling — reuses objects but still stores all state in each object.

**AP3:** Use Flyweight pattern — split state into intrinsic (shared) and extrinsic (passed in). Many objects share one flyweight, saving memory.

## The Pattern Structure

```
Client
  |
  | requests flyweight
  v
FlyweightFactory (cache/pool)
  |
  | returns shared or cached flyweight
  v
CharacterStyle (flyweight)         ← shared object, stores intrinsic state
  font, fontSize, color, bold

Client passes extrinsic state (row, col) when calling render()
```

```
Without Flyweight:                    With Flyweight:

Object 1: [A, Arial, 12, black, 0,0]   Object 1: [A, →Style1, 0,0]
Object 2: [B, Arial, 12, black, 0,1]   Object 2: [B, →Style1, 0,1]
Object 3: [C, Arial, 12, black, 0,2]   Object 3: [C, →Style1, 0,2]
Object 4: [D, Arial, 14, red,   1,0]   Object 4: [D, →Style2, 1,0]
Object 5: [E, Arial, 14, red,   1,1]   Object 5: [E, →Style2, 1,1]

Each stores full data                  Style1: [Arial, 12, black]  ← shared
                                       Style2: [Arial, 14, red]   ← shared
                                       100,000 objects share ~5 styles
```

## Implementation

### Step 1: Flyweight — holds only intrinsic (shared) state

```java
class CharacterStyle {
    private final String font;
    private final int fontSize;
    private final String color;
    private final boolean bold;

    CharacterStyle(String font, int fontSize, String color, boolean bold) {
        this.font = font;
        this.fontSize = fontSize;
        this.color = color;
        this.bold = bold;
    }

    // Extrinsic state (row, col) passed in as parameter, NOT stored
    void render(char value, int row, int col) {
        System.out.println("Draw '" + value + "' at (" + row + "," + col + ") "
            + font + " " + fontSize + " " + color + (bold ? " bold" : ""));
    }
}
```

### Step 2: Flyweight Factory — caches and reuses flyweights

```java
class StyleFactory {
    private static Map<String, CharacterStyle> cache = new HashMap<>();

    static CharacterStyle getStyle(String font, int fontSize, String color, boolean bold) {
        String key = font + "-" + fontSize + "-" + color + "-" + bold;

        if (!cache.containsKey(key)) {
            cache.put(key, new CharacterStyle(font, fontSize, color, bold));
            System.out.println("Created new style: " + key);
        }

        return cache.get(key);  // return shared instance
    }
}
```

### Step 3: Context object — holds extrinsic state + reference to flyweight

```java
class CharacterContext {
    char value;              // which character
    int row, col;            // position (extrinsic — unique per character)
    CharacterStyle style;    // shared flyweight (intrinsic)

    CharacterContext(char value, int row, int col, CharacterStyle style) {
        this.value = value;
        this.row = row;
        this.col = col;
        this.style = style;
    }

    void render() {
        style.render(value, row, col);  // pass extrinsic state to flyweight
    }
}
```

### Step 4: Client code

```java
// All characters share the same style object
CharacterStyle normalStyle = StyleFactory.getStyle("Arial", 12, "black", false);
CharacterStyle headingStyle = StyleFactory.getStyle("Arial", 24, "blue", true);

// 100,000 characters, but only 2 style objects in memory
List<CharacterContext> document = new ArrayList<>();
document.add(new CharacterContext('H', 0, 0, headingStyle));
document.add(new CharacterContext('i', 0, 1, headingStyle));
document.add(new CharacterContext('T', 1, 0, normalStyle));
document.add(new CharacterContext('h', 1, 1, normalStyle));
document.add(new CharacterContext('i', 1, 2, normalStyle));
document.add(new CharacterContext('s', 1, 3, normalStyle));
// ... 99,994 more, all pointing to normalStyle or headingStyle

for (CharacterContext c : document) {
    c.render();
}
```

## Before vs After

**Before (without Flyweight):**

```
100,000 characters x (char + font + fontSize + color + bold + row + col)
= 100,000 full objects in memory
```

**After (with Flyweight):**

```
2 shared style objects (flyweights)
+ 100,000 lightweight context objects (char + row + col + reference to style)
= ~60-70% memory saved
```

## The Memory Math

```
Without Flyweight:
100,000 objects x ~100 bytes each = ~10 MB

With Flyweight:
2 style objects x ~50 bytes = 100 bytes
100,000 context objects x ~30 bytes = ~3 MB
Total = ~3 MB (70% saved)
```

## Important Rules

Rule | Why
-- | --
Flyweight must be IMMUTABLE | If one client changes it, all clients sharing it would be affected
Intrinsic state stored IN the flyweight | Shared data lives inside the shared object
Extrinsic state passed AS parameters | Unique data is never stored in the flyweight
Factory controls creation | Ensures objects are reused, not duplicated
Identity check: use equals(), not == | Multiple references point to same object

## Real Examples

Example | Flyweight (shared) | Extrinsic (unique) | Factory
-- | -- | -- | --
Text editor | CharacterStyle (font, size, color) | Position (row, col) | StyleFactory
Game - forest | TreeType (texture, mesh, color) | Position (x, y, z) | TreeTypeFactory
Game - bullets | BulletType (sprite, damage, speed) | Position, direction | BulletTypeFactory
Chess game | ChessPieceType (image, color) | Board position | PieceFactory
String pool | String object | Variable reference | String.intern() / literal pool
Integer cache | Integer object | Variable reference | Integer.valueOf()

**Java/JDK usage:**

- `Integer.valueOf(10)` — caches Integer objects for -128 to 127. Same value returns same object:
```java
Integer a = Integer.valueOf(10);
Integer b = Integer.valueOf(10);
System.out.println(a == b);  // true — same cached object (flyweight)

Integer c = Integer.valueOf(200);
Integer d = Integer.valueOf(200);
System.out.println(c == d);  // false — outside cache range
```

- `String` pool — identical string literals share one object:
```java
String s1 = "hello";
String s2 = "hello";
System.out.println(s1 == s2);  // true — same pooled object (flyweight)
```

- `Boolean.valueOf()`, `Byte.valueOf()`, `Short.valueOf()` — same caching idea

## Design Principles

Principle | How Flyweight uses it
-- | --
Separation of concerns | Split state into intrinsic (shared) and extrinsic (contextual)
Single Responsibility | Flyweight handles shared behavior, context handles unique state
DRY (Don't Repeat Yourself) | Shared data stored once, not duplicated across objects
Open/Closed | New flyweight types can be added without changing existing code
Immutability | Flyweights are immutable to safely share across clients

## Comparison with Other Patterns

### Flyweight vs Singleton

```
Singleton: ONE shared instance of a class
Flyweight: MANY shared instances, one per unique intrinsic state combination

Singleton: only 1 object ever
Flyweight: pool of reusable objects (could be 1, could be 50)
```

### Flyweight vs Prototype

```
Prototype: create new objects by COPYING existing ones
Flyweight: SHARE existing objects instead of creating new ones

Prototype: each clone is independent (different objects)
Flyweight: multiple references point to SAME object
```

### Flyweight vs Object Pool

```
Object Pool: reuses MUTABLE objects (take, use, return)
Flyweight: shares IMMUTABLE objects (take, use, keep sharing)

Object Pool: one object used by one client at a time
Flyweight: one object shared by many clients simultaneously
```

### Flyweight vs Facade

```
Facade: simplifies a complex interface
Flyweight: optimizes memory by sharing state

Different problems entirely.
Facade is about API simplicity.
Flyweight is about memory efficiency.
```

## The Progression Story (for interviews)

Step | What happens | Problem
-- | -- | --
1 | Small number of objects | No memory issue
2 | System scales to thousands/millions of objects | Memory usage explodes
3 | Notice most objects share common data | Redundant storage
4 | Split state into intrinsic (shared) and extrinsic (unique) | Flyweight pattern
5 | Factory caches flyweights, clients pass extrinsic state | Memory drops dramatically

## How to Identify When to Use Flyweight

Checklist:
- Large number of similar objects? Yes
- Most of their data is the same across objects? Yes
- Can you split state into shared and unique? Yes
- Can the shared part be made immutable? Yes

If all four are yes → Flyweight is a good fit.

## Quick Reference

Question | Answer
-- | --
What problem does it solve? | Excessive memory usage from many similar objects with duplicated state
What is intrinsic state? | Data shared across many objects (font, texture, type) — stored IN the flyweight
What is extrinsic state? | Data unique to each object (position, context) — passed AS a parameter
What is the factory? | Cache that ensures flyweights are reused, not duplicated
Must flyweights be immutable? | Yes. If one client mutates it, all clients sharing it are affected.
How much memory does it save? | Depends on data overlap. Often 50-90% reduction.
How is it different from Singleton? | Singleton = one instance. Flyweight = pool of shared instances.
How is it different from Object Pool? | Object Pool reuses mutable objects. Flyweight shares immutable objects.
Java example | Integer.valueOf() caching -128 to 127, String literal pool
Interview one-liner | Flyweight pattern shares common intrinsic state across many objects through a factory cache, dramatically reducing memory usage when large numbers of similar objects exist.
