# Facade Pattern

## CAUSE and EFFECT

```
CAUSE (the technique):
"Provide a single simplified interface over a complex subsystem"

EFFECT (the benefit):
"Client code becomes simple and decoupled from subsystem internals"
```

## The Problem in Normal Code

Suppose you build a **home theater system** that plays a movie.

```java
class Projector {
    void on() { System.out.println("Projector on"); }
    void setInput(String input) { System.out.println("Input set to " + input); }
    void setResolution(String res) { System.out.println("Resolution: " + res); }
}

class SoundSystem {
    void on() { System.out.println("Sound on"); }
    void setVolume(int vol) { System.out.println("Volume: " + vol); }
    void setSurroundMode() { System.out.println("Surround mode on"); }
}

class DVDPlayer {
    void on() { System.out.println("DVD on"); }
    void load(String movie) { System.out.println("Loading: " + movie); }
    void play() { System.out.println("Playing"); }
}

class Lights {
    void dim(int level) { System.out.println("Lights dimmed to " + level); }
}
```

Client code must know every subsystem class and the correct order of operations:

```java
// Client wants to just "watch a movie" but must do all this:
Projector projector = new Projector();
SoundSystem sound = new SoundSystem();
DVDPlayer dvd = new DVDPlayer();
Lights lights = new Lights();

lights.dim(10);
projector.on();
projector.setInput("DVD");
projector.setResolution("1080p");
sound.on();
sound.setVolume(20);
sound.setSurroundMode();
dvd.on();
dvd.load("Inception");
dvd.play();
```

**What goes wrong as the system grows:**

- Client is tightly coupled to every subsystem class
- Client must know the correct sequence of calls
- If any subsystem API changes, every client must be updated
- The same setup sequence gets duplicated across multiple places
- Adding a new subsystem (e.g., CurtainController) means changing every client

## Three Approaches

**AP1:** Client directly calls all subsystem methods — tight coupling, duplication, fragile.

**AP2:** Create a utility/helper with static methods — slightly better but still exposes internals and is hard to extend.

**AP3:** Use Facade pattern — one class wraps the entire subsystem and exposes simple methods. Client only talks to the facade.

## The Pattern Structure

```
Client
  |
  | calls simple methods
  v
HomeTheaterFacade
  |
  | internally manages
  v
┌─────────────────────────────────┐
│  Projector                      │
│  SoundSystem                    │
│  DVDPlayer                      │
│  Lights                         │
│  (subsystem classes)            │
└─────────────────────────────────┘
```

Key insight: The Facade does NOT add new functionality. It just simplifies access to existing functionality. The subsystem classes still exist and can still be used directly if needed.

## Implementation

### Step 1: Subsystem classes (already exist, unchanged)

```java
class Projector {
    void on() { System.out.println("Projector on"); }
    void setInput(String input) { System.out.println("Input: " + input); }
    void setResolution(String res) { System.out.println("Resolution: " + res); }
    void off() { System.out.println("Projector off"); }
}

class SoundSystem {
    void on() { System.out.println("Sound on"); }
    void setVolume(int vol) { System.out.println("Volume: " + vol); }
    void setSurroundMode() { System.out.println("Surround mode"); }
    void off() { System.out.println("Sound off"); }
}

class DVDPlayer {
    void on() { System.out.println("DVD on"); }
    void load(String movie) { System.out.println("Loading: " + movie); }
    void play() { System.out.println("Playing"); }
    void stop() { System.out.println("Stopped"); }
    void off() { System.out.println("DVD off"); }
}

class Lights {
    void dim(int level) { System.out.println("Lights: " + level + "%"); }
    void on() { System.out.println("Lights on"); }
}
```

### Step 2: Facade — wraps the subsystem

```java
class HomeTheaterFacade {
    private Projector projector;
    private SoundSystem sound;
    private DVDPlayer dvd;
    private Lights lights;

    HomeTheaterFacade(Projector projector, SoundSystem sound,
                      DVDPlayer dvd, Lights lights) {
        this.projector = projector;
        this.sound = sound;
        this.dvd = dvd;
        this.lights = lights;
    }

    void watchMovie(String movie) {
        lights.dim(10);
        projector.on();
        projector.setInput("DVD");
        projector.setResolution("1080p");
        sound.on();
        sound.setVolume(20);
        sound.setSurroundMode();
        dvd.on();
        dvd.load(movie);
        dvd.play();
    }

    void endMovie() {
        dvd.stop();
        dvd.off();
        sound.off();
        projector.off();
        lights.on();
    }
}
```

### Step 3: Client code — simple, one call

```java
HomeTheaterFacade theater = new HomeTheaterFacade(
    new Projector(), new SoundSystem(), new DVDPlayer(), new Lights()
);

// Before: 10 lines of setup across 4 classes
// After: 1 line
theater.watchMovie("Inception");

// Later
theater.endMovie();
```

## Before vs After

**Before (without Facade):**

```java
// Every client must know all classes and correct order
lights.dim(10);
projector.on();
projector.setInput("DVD");
projector.setResolution("1080p");
sound.on();
sound.setVolume(20);
sound.setSurroundMode();
dvd.on();
dvd.load("Inception");
dvd.play();
```

**After (with Facade):**

```java
theater.watchMovie("Inception");  // done
```

## Important: Facade Does NOT Hide the Subsystem

The subsystem classes are still accessible. The facade is a convenience, not a restriction. If a client needs fine-grained control, it can still use subsystem classes directly:

```java
// Use facade for common operations
theater.watchMovie("Inception");

// But still access subsystem directly for special cases
sound.setVolume(50);  // still allowed
```

This is a key difference from other patterns. Facade simplifies but does not restrict.

## Real Examples

Example | Facade | Subsystem it wraps
-- | -- | --
Home theater | HomeTheaterFacade | Projector, Sound, DVD, Lights
Computer startup | Computer.start() | CPU, Memory, HardDrive, BIOS
Online ordering | OrderFacade.placeOrder() | InventoryService, PaymentService, ShippingService, NotificationService
File operations | java.nio.file.Files | FileSystem, FileChannel, Path, InputStream, OutputStream
JDBC | DriverManager.getConnection() | Driver, Connection, Socket, Protocol handling
Spring Boot | @SpringBootApplication | ComponentScan, AutoConfiguration, PropertySource, EmbeddedServer
SLF4J | LoggerFactory.getLogger() | Log4j, Logback, JUL, or other logging frameworks

**Java/JDK usage:**
- `java.nio.file.Files` — simple methods like `Files.readString()`, `Files.copy()` over complex low-level I/O classes
- `javax.faces.context.FacesContext` — wraps multiple JSF subsystems behind one object

## When Does the Need Arise?

Step | What happens | Problem
-- | -- | --
1 | System has 2-3 classes | Direct calls are fine
2 | System grows to 5-10 classes | Client must orchestrate many classes in correct order
3 | Multiple clients duplicate the same orchestration | Code duplication, fragile, hard to change
4 | Subsystem API changes | Every client breaks
5 | Use Facade | One place to manage orchestration, clients stay simple

## Design Principles

Principle | How Facade uses it
-- | --
Least Knowledge (Law of Demeter) | Client only talks to one object (facade), not many subsystem objects
Loose Coupling | Client is decoupled from subsystem internals
Single Responsibility | Facade handles orchestration, subsystem classes handle their own work
Open/Closed | Add new subsystems without changing client code (only update facade)

## Comparison with Other Patterns

### Facade vs Adapter

```
Facade: simplifies a COMPLEX subsystem into one easy interface
Adapter: converts ONE incompatible interface into a compatible one

Facade: many classes → one simple API
Adapter: one class → different interface shape
```

```
FACADE:
Client → Facade → [ClassA, ClassB, ClassC, ClassD]
                    wraps many classes

ADAPTER:
Client → Adapter → ClassA
                    wraps one class with wrong interface
```

### Facade vs Mediator

```
Facade: one-directional. Client calls facade, facade calls subsystems.
         Subsystems do NOT know about the facade.

Mediator: bi-directional. Objects communicate THROUGH the mediator.
          Objects know about the mediator and the mediator knows about objects.
```

```
FACADE (one-way):
Client → Facade → Subsystems
                   (subsystems don't know about facade)

MEDIATOR (two-way):
ObjectA ↔ Mediator ↔ ObjectB
ObjectC ↔ Mediator ↔ ObjectD
          (all objects talk through mediator)
```

### Facade vs Bridge

```
Facade: wraps complexity behind a simple interface (one hierarchy)
Bridge: separates two independently varying hierarchies (two hierarchies)

Facade solves: complex subsystem access
Bridge solves: class explosion from multiple dimensions
```

### Facade vs Composite

```
Facade: simplifies access to a group of DIFFERENT classes
Composite: treats individual and group of SAME type uniformly

Facade: heterogeneous subsystem (Projector, Sound, DVD are different types)
Composite: homogeneous tree (File and Folder share the same interface)
```

## The Progression Story (for interviews)

Step | What happens | Approach
-- | -- | --
1 | Small subsystem, 2-3 classes | Direct calls work fine
2 | Subsystem grows, client must call 10 methods across 4 classes in order | Gets messy, duplicated
3 | Multiple clients repeat the same orchestration | Code duplication, fragile
4 | Use Facade: one class wraps the subsystem with simple methods | Client calls one method, facade handles the rest

## Quick Reference

Question | Answer
-- | --
What problem does it solve? | Complex subsystem requires many coordinated calls from clients
What does the facade do? | Wraps a subsystem and exposes simple methods
Does it hide the subsystem? | No. Subsystem is still accessible for fine-grained control
Does it add new functionality? | No. It only simplifies access to existing functionality
Key rule | One simplified interface over many complex subsystem classes
Design principle | Least Knowledge / Law of Demeter — talk to one object, not many
How is it different from Adapter? | Facade simplifies many classes. Adapter converts one interface.
How is it different from Mediator? | Facade is one-way (client → subsystem). Mediator is two-way.
Java example | java.nio.file.Files wrapping low-level I/O
Interview one-liner | Facade pattern provides a simplified interface over a complex subsystem, so clients only interact with one easy entry point instead of orchestrating many classes directly.
