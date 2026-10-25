# LLD - Design Patterns
## Design pattern

separation of concern - take some code out of business logic

1. Factory Pattern - take object creation outside and chose runtime using parameter
2. Abstract Factory Pattern - take family of object creation
3. Builder - takes out complex creation out of business logic (inner class)
4. Prototype - take cloning out of business logic
5. Strategy - decoupling algorithms from business logic.
6. Decorator - it allows you to add behavior to an object dynamically without changing
7. Adapter - all the conversion logic is encapsulated inside the adapter
8. Proxy - business logic doesn’t have to handle access control, caching, logging, or lazy loading
9. Command - all of this is encapsulated in command objects, leaving business logic focused on commands.
10. Facade - the client/business logic does not have to deal with multiple classes


## When to Use Which Pattern

| Pattern | Use When | Example |
|---|---|---|
| **Strategy** | Multiple algorithms, swap at runtime | Payment modes, sorting strategies |
| **Observer** | One-to-many notifications | Event listeners, pub-sub |
| **Factory** | Create objects without exposing creation logic | VehicleFactory, ShapeFactory |
| **Singleton** | One instance globally | DB connection, Logger |
| **Decorator** | Add behavior dynamically without subclassing | Pizza toppings, I/O streams |
| **Command** | Encapsulate request as object, undo/redo | Remote control, task queue |
| **State** | Object behavior changes with internal state | Vending machine, traffic light |
| **Proxy** | Control access to an object | Caching proxy, access control |
| **Builder** | Complex object construction step-by-step | Query builder, meal builder |
| **Adapter** | Make incompatible interfaces work together | Legacy system integration |

## SOLID Principles (One-liner each)

| Principle | Meaning | Violation Smell |
|---|---|---|
| **S** - Single Responsibility | One class = one reason to change | God class doing everything |
| **O** - Open/Closed | Open for extension, closed for modification | if-else chains for new types |
| **L** - Liskov Substitution | Subtypes must be substitutable for base | Square extending Rectangle breaks |
| **I** - Interface Segregation | Small focused interfaces | Forcing empty method implementations |
| **D** - Dependency Inversion | Depend on abstractions, not concretions | `new ConcreteClass()` everywhere |

## LLD Interview Template

```
1. Clarify Requirements (2 min)
   → Who are the actors? What actions?

2. Identify Core Objects/Entities (3 min)
   → Nouns = classes, Verbs = methods

3. Define Relationships (3 min)
   → Has-a, Is-a, Uses

4. Write Class Diagram (5 min)
   → Classes, fields, methods, interfaces

5. Identify Design Patterns (2 min)
   → Which patterns fit naturally?

6. Code Key Classes (15 min)
   → Focus on core logic, not boilerplate
```


# Abstract Factory Pattern

## Core Idea

Each factory creates a set of related style/theme objects.

But all factories still create the same product categories.

---

# Example

| Factory | Products Created |
|---|---|
| WindowsFactory | WindowsButton, WindowsCheckbox |
| MacFactory | MacButton, MacCheckbox |

---

# Important Observation

Both factories produce:

- Button
- Checkbox

But in different families/styles.

---

# Abstract Factory - Simplified Class Diagram

```txt
                    +-------------------+
                    |   GUIFactory      |
                    +-------------------+
                    | +createButton()   |
                    | +createCheckbox() |
                    +-------------------+
                               ^
                 -------------------------------
                 |                             |
      +-------------------+         +-------------------+
      | WindowsFactory    |         | MacFactory        |
      +-------------------+         +-------------------+
                 |                             |
         ----------------             ----------------
         |              |             |              |
         v              v             v              v

   +---------------+  +----------------+  +-----------+  +---------------+
   | WindowsButton |  | WindowsCheckbox|  | MacButton |  | MacCheckbox   |
   +---------------+  +----------------+  +-----------+  +---------------+
           ^                    ^               ^                 ^
           |                    |               |                 |
           ----------------------               -------------------
                      |                                   |
                +-----------+                      +-------------+
                |  Button   |                      |  Checkbox   |
                +-----------+                      +-------------+


## My Notes
<!-- Add your own observations, mistakes, and learnings below -->
