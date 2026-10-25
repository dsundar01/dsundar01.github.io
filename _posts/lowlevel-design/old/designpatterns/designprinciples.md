This is the core question. Each pattern is chosen because a specific design principle is being violated or needs to be applied.

## Design Principle → Pattern Mapping

### SOLID Principles

**S — Single Responsibility Principle (SRP)**
"A class should have only one reason to change."

When violated | You see | Pattern to apply
-- | -- | --
Object creation logic mixed with business logic | `new` calls scattered in main code | Factory Method, Abstract Factory, Builder
State-dependent branching mixed with business logic | Every method has if/else for state | State
Access control / caching / logging mixed with core logic | Real class bloated with non-core concerns | Proxy
Subsystem orchestration mixed with client logic | Client coordinates 10 classes manually | Facade
Undo logic mixed with domain logic | Editor class manages its own history stack | Command + Memento

**O — Open/Closed Principle (OCP)**
"Open for extension, closed for modification."

When violated | You see | Pattern to apply
-- | -- | --
Adding a new algorithm requires changing existing if/else | Growing switch/if block for selecting behavior | Strategy
Adding a new state requires changing every method | New state = touch every method in the class | State
Adding a new notification type requires changing sender code | Both sides change together | Bridge
Adding a new type requires changing client code | `instanceof` checks everywhere | Composite
Adding a new feature requires modifying the base class | Subclass explosion for every feature combo | Decorator
Adding a new operation on objects requires changing object classes | New operation = touch every model class | Visitor

**L — Liskov Substitution Principle (LSP)**
"Subtypes must be substitutable for their base types."

When violated | You see | Pattern to apply
-- | -- | --
Client treats objects differently based on concrete type | `instanceof` + type casting | Composite (treat leaf and composite uniformly)
Proxy must be transparent to client | Client should not know it's using a proxy | Proxy (same interface as real object)

**I — Interface Segregation Principle (ISP)**
"Clients should not be forced to depend on methods they don't use."

When violated | You see | Pattern to apply
-- | -- | --
Client depends on a complex API with 50 methods | Using only 3 methods from a huge interface | Facade (expose only what client needs)
Fat interface forces implementing unused methods | Empty method implementations | Adapter (adapt to a simpler interface)

**D — Dependency Inversion Principle (DIP)**
"Depend on abstractions, not on concrete classes."

When violated | You see | Pattern to apply
-- | -- | --
Client creates concrete objects directly | `new ConcreteClass()` everywhere | Factory Method, Abstract Factory
Client depends on specific implementation | Changing implementation means changing client | Bridge, Strategy
Invoker depends on specific action code | Button directly calls editor.bold() | Command (depend on Command interface)

---

### Other Key Principles

**Encapsulation**
"Hide internal details from outside."

When violated | You see | Pattern to apply
-- | -- | --
Internal state exposed for undo/save | Public getters/setters for every field | Memento (originator saves its own state)
Algorithm details exposed to client | Client knows implementation steps | Strategy, Template Method
Object creation details exposed | Client knows constructor complexity | Builder, Factory

**Composition over Inheritance**
"Prefer holding a reference over extending a class."

When violated | You see | Pattern to apply
-- | -- | --
Subclass explosion from combining features | BufferedEncryptedCompressedStream | Decorator (wrap instead of inherit)
Subclass explosion from multiple dimensions | 3 types x 3 channels = 9 classes | Bridge (compose dimensions)
Behavior locked into inheritance tree | Can't change behavior at runtime | Strategy (plug in via interface)

**Law of Demeter / Least Knowledge**
"Talk only to your immediate friends."

When violated | You see | Pattern to apply
-- | -- | --
Client reaches through multiple objects | `order.getCustomer().getAddress().getCity()` | Facade (one entry point)
Many objects talk directly to each other | A↔B, A↔C, B↔C, B↔D spaghetti | Mediator (centralize communication)

**DRY — Don't Repeat Yourself**
"Every piece of knowledge should have a single source."

When violated | You see | Pattern to apply
-- | -- | --
Same algorithm skeleton repeated across classes | Tea/Coffee both have boil→brew→pour→add steps | Template Method
Same shared data duplicated across objects | 100,000 objects storing same font data | Flyweight
Same action triggered from 3 places with same code | Button, menu, shortcut all duplicate action code | Command (one command object reused)

**Hollywood Principle — "Don't call us, we'll call you"**
"High-level modules control the flow."

When violated | You see | Pattern to apply
-- | -- | --
Objects actively poll for changes | While loop checking if something changed | Observer (push notifications instead)
Subclass controls the algorithm flow | Subclass overrides entire process | Template Method (base class controls flow, subclass fills in steps)

---

## The Decision Tree

```
What is the problem in your code?
│
├─ Object creation is complex or scattered
│   ├─ Need one instance only → Singleton
│   ├─ Client should not know exact class → Factory Method
│   ├─ Need a family of related objects → Abstract Factory
│   ├─ Object has many optional parts → Builder
│   └─ New objects are copies of existing → Prototype
│
├─ Object structure / wiring is messy
│   ├─ Incompatible interface → Adapter
│   ├─ Two+ dimensions cause class explosion → Bridge
│   ├─ Single vs group treated differently → Composite
│   ├─ Features cause subclass explosion → Decorator
│   ├─ Subsystem too complex for client → Facade
│   ├─ Too many similar objects waste memory → Flyweight
│   └─ Need controlled access to object → Proxy
│
├─ Behavior / control flow is messy
│   ├─ Algorithm selection via if/else → Strategy
│   ├─ Behavior changes with internal state → State
│   ├─ Need undo/redo/queue actions → Command
│   ├─ Many dependents react to one change → Observer
│   ├─ Algorithm skeleton shared, steps vary → Template Method
│   ├─ Traverse collection without exposing internals → Iterator
│   ├─ Many objects communicate directly → Mediator
│   ├─ Save/restore state without breaking encapsulation → Memento
│   ├─ Request passes through handler chain → Chain of Responsibility
│   └─ Add operations without changing object classes → Visitor
```

## Compact Reference: Principle → Pattern → Problem

Principle | Pattern | Problem it fixes
-- | -- | --
SRP | Proxy | Core class cluttered with caching/logging/access control
SRP | Facade | Client orchestrates too many subsystem classes
SRP | Command | Action logic tied to UI/invoker
SRP | State | Every method has state-dependent branching
OCP | Strategy | Adding algorithm = modifying if/else
OCP | Decorator | Adding feature = new subclass
OCP | Bridge | Adding dimension = class explosion
OCP | Composite | Adding type = new instanceof check
OCP | Visitor | Adding operation = modifying every class
OCP | State | Adding state = modifying every method
Encapsulation | Memento | Internal state exposed for save/restore
Encapsulation | Strategy | Algorithm internals exposed to client
Composition over Inheritance | Bridge | Inheritance explosion from multiple dimensions
Composition over Inheritance | Decorator | Inheritance explosion from feature combinations
Composition over Inheritance | Strategy | Behavior locked in inheritance tree
DIP | Factory Method | Client depends on concrete classes
DIP | Command | Invoker depends on specific receiver methods
DIP | Bridge | Abstraction coupled to implementation
Law of Demeter | Facade | Client reaches into subsystem internals
Law of Demeter | Mediator | Objects talk to too many peers
DRY | Template Method | Algorithm skeleton duplicated
DRY | Flyweight | Shared data duplicated across objects
DRY | Command | Same action code duplicated in multiple places
LSP | Composite | Client treats subtypes differently
LSP | Proxy | Substitute must be transparent

## Interview-Safe One-Liner

> "I choose a design pattern based on which SOLID principle or design rule is being violated. The pattern is the fix for that specific violation."
