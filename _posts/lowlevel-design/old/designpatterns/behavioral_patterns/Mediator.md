

# Mediator Pattern

## CAUSE and EFFECT

```
CAUSE (the technique):
"Introduce a central mediator object that encapsulates how a set
of objects interact, so objects communicate through the mediator
instead of directly with each other"

EFFECT (the benefit):
"Eliminates many-to-many direct dependencies between objects,
replacing them with one-to-many dependencies on the mediator"
```

**Design Principle:** Law of Demeter / Least Knowledge — objects should only talk to their immediate friends, not to friends of friends.

## The Problem in Normal Code

Suppose you build a **chat application** with users in a chat room.

```java
class User {
    private String name;
    private List<User> contacts = new ArrayList<>();

    User(String name) { this.name = name; }

    void addContact(User user) {
        contacts.add(user);
    }

    void sendMessage(String message) {
        for (User contact : contacts) {
            contact.receive(message, this);
        }
    }

    void receive(String message, User from) {
        System.out.println(name + " received from " + from.name + ": " + message);
    }
}
```

Client code:

```java
User alice = new User("Alice");
User bob = new User("Bob");
User charlie = new User("Charlie");
User dave = new User("Dave");

// Every user must know every other user directly
alice.addContact(bob);
alice.addContact(charlie);
alice.addContact(dave);
bob.addContact(alice);
bob.addContact(charlie);
bob.addContact(dave);
charlie.addContact(alice);
charlie.addContact(bob);
charlie.addContact(dave);
dave.addContact(alice);
dave.addContact(bob);
dave.addContact(charlie);
// 4 users = 12 connections (n × (n-1))

alice.sendMessage("Hello everyone");
```

**What goes wrong:**

- Every object holds direct references to every other object — **violates Law of Demeter**
- 4 users = 12 connections. 10 users = 90 connections. 100 users = 9,900 connections — **exponential coupling**
- Adding a new user means updating EVERY existing user's contact list — **violates Open/Closed Principle**
- Removing a user means cleaning up references in EVERY other user — **fragile**
- Communication rules (e.g., "block user", "mute", "broadcast to group only") must be implemented in EVERY user — **violates Single Responsibility**
- Testing one user requires creating all its contacts — **tight coupling makes testing hard**

**Design Principle violated:** SRP — User class handles both its own behavior AND communication routing.

## The Connection Growth Problem

Users | Without Mediator (direct connections) | With Mediator (connections to mediator)
-- | -- | --
4 | 12 | 4
10 | 90 | 10
50 | 2,450 | 50
100 | 9,900 | 100

Formula:
- Without Mediator: $n \times (n-1)$ connections (every object knows every other)
- With Mediator: $n$ connections (every object knows only the mediator)

## Three Approaches

**AP1:** Every object holds direct references to every other — many-to-many coupling, exponential connections, fragile.

**AP2:** Use Observer pattern — decouples somewhat but doesn't centralize communication logic; every observer still reacts independently.

**AP3:** Use Mediator pattern — all communication goes through one central mediator. Objects only know the mediator. Communication rules live in one place.

**Design Principle for choosing AP3:** Separation of Concerns — move communication logic out of participating objects into a dedicated coordinator.

## The Key Insight

Instead of objects talking to each other directly, they all talk to a mediator. The mediator decides who gets the message and how.

```
Without Mediator (many-to-many):
Alice ↔ Bob
Alice ↔ Charlie
Alice ↔ Dave
Bob ↔ Charlie
Bob ↔ Dave
Charlie ↔ Dave
(every object knows every other)

With Mediator (one-to-many):
Alice → ChatRoom ← Bob
            ↑
Charlie → ChatRoom ← Dave
(every object knows only the ChatRoom)
```

**Design Principle:** Dependency Inversion — objects depend on the mediator abstraction, not on each other's concrete classes.

## The Pattern Structure

```
Colleague (User)              Mediator (ChatRoom)
  |                              |
  | sends message to             | receives and routes
  |────────────────────>         |
  |                              | decides who gets it
  | <────────────────────        |
  | receives routed message      |

Users do NOT know about each other.
Users ONLY know the mediator.
Mediator knows ALL users.
Mediator controls ALL communication rules.
```

**Design Principle:** Single Responsibility — Users handle their own behavior. Mediator handles routing and rules.

## Implementation

### Step 1: Mediator interface

```java
interface ChatMediator {
    void sendMessage(String message, User sender);
    void addUser(User user);
}
```

**Design Principle:** Dependency Inversion — Users depend on this interface, not on concrete ChatRoom.

### Step 2: Colleague — knows only the mediator

```java
class User {
    private String name;
    private ChatMediator mediator;  // only reference — NOT other users

    User(String name, ChatMediator mediator) {
        this.name = name;
        this.mediator = mediator;
    }

    void send(String message) {
        System.out.println(name + " sends: " + message);
        mediator.sendMessage(message, this);  // delegate to mediator
    }

    void receive(String message, User from) {
        System.out.println(name + " received from " + from.getName() + ": " + message);
    }

    String getName() { return name; }
}
```

**Design Principle:** Law of Demeter — User talks only to its immediate friend (mediator), never to other Users directly.

### Step 3: Concrete Mediator — routes messages, holds all rules

```java
class ChatRoom implements ChatMediator {
    private List<User> users = new ArrayList<>();

    public void addUser(User user) {
        users.add(user);
        System.out.println(user.getName() + " joined the chat");
    }

    public void sendMessage(String message, User sender) {
        for (User user : users) {
            if (user != sender) {  // don't send to self
                user.receive(message, sender);
            }
        }
    }
}
```

**Design Principle:** Single Responsibility — ALL routing logic is centralized here. Change routing? Change one class.

### Step 4: Client code

```java
ChatMediator chatRoom = new ChatRoom();

User alice = new User("Alice", chatRoom);
User bob = new User("Bob", chatRoom);
User charlie = new User("Charlie", chatRoom);
User dave = new User("Dave", chatRoom);

chatRoom.addUser(alice);
chatRoom.addUser(bob);
chatRoom.addUser(charlie);
chatRoom.addUser(dave);

alice.send("Hello everyone!");
// Bob received from Alice: Hello everyone!
// Charlie received from Alice: Hello everyone!
// Dave received from Alice: Hello everyone!

bob.send("Hey Alice!");
// Alice received from Bob: Hey Alice!
// Charlie received from Bob: Hey Alice!
// Dave received from Bob: Hey Alice!
```

## Before vs After

**Before (without Mediator):**

```java
// Adding a 5th user — must update all 4 existing users
alice.addContact(eve);
bob.addContact(eve);
charlie.addContact(eve);
dave.addContact(eve);
eve.addContact(alice);
eve.addContact(bob);
eve.addContact(charlie);
eve.addContact(dave);
// 8 new connections for 1 new user
```

**After (with Mediator):**

```java
// Adding a 5th user — update only the mediator
User eve = new User("Eve", chatRoom);
chatRoom.addUser(eve);
// 1 connection. Done. Eve can now send/receive with everyone.
```

**Design Principle:** Open/Closed — adding a new user does NOT modify existing users or the mediator logic.

## Advanced: Mediator with Rules

The real power of Mediator is centralizing complex communication rules:

```java
class SmartChatRoom implements ChatMediator {
    private List<User> users = new ArrayList<>();
    private Map<User, Set<User>> blockedUsers = new HashMap<>();
    private Map<User, Boolean> mutedUsers = new HashMap<>();

    public void addUser(User user) {
        users.add(user);
        blockedUsers.put(user, new HashSet<>());
        mutedUsers.put(user, false);
    }

    public void blockUser(User blocker, User blocked) {
        blockedUsers.get(blocker).add(blocked);
    }

    public void muteUser(User user) {
        mutedUsers.put(user, true);
    }

    public void sendMessage(String message, User sender) {
        // Rule 1: muted users can't send
        if (mutedUsers.getOrDefault(sender, false)) {
            System.out.println(sender.getName() + " is muted");
            return;
        }

        for (User user : users) {
            if (user == sender) continue;

            // Rule 2: skip if receiver blocked the sender
            if (blockedUsers.get(user).contains(sender)) continue;

            user.receive(message, sender);
        }
    }
}
```

```java
SmartChatRoom room = new SmartChatRoom();
// ... add users ...

room.blockUser(bob, alice);      // Bob blocks Alice
room.muteUser(charlie);          // Charlie is muted

alice.send("Hello");
// Bob does NOT receive (blocked Alice)
// Charlie receives
// Dave receives

charlie.send("Hi");
// "Charlie is muted" — nobody receives
```

**Design Principle:** Single Responsibility — ALL rules (block, mute, broadcast) live in ONE place. Without mediator, each User would need to implement blocking, muting, etc.

**Without Mediator, these rules would be scattered:**

```java
// Inside User.sendMessage() — every user handles routing
void sendMessage(String message) {
    for (User contact : contacts) {
        if (this.isMuted) return;                    // rule in User
        if (contact.hasBlocked(this)) continue;      // rule in User
        contact.receive(message, this);
    }
}
// Every User implements the same rules. DRY violated.
```

## Real Examples

Example | Colleagues | Mediator | Rules it centralizes
-- | -- | -- | --
Chat room | Users | ChatRoom | Who receives, block, mute, broadcast
Airport | Airplanes | ATC (Air Traffic Control) | Landing order, runway assignment, collision avoidance
UI form | Input fields, buttons, dropdowns | FormController | "When country changes, update state dropdown and zip format"
Stock exchange | Buyers, Sellers | Exchange | Order matching, pricing, trade execution
Smart home | Lights, Thermostat, Security, Sprinkler | HomeController | "Fire detected → turn off AC, turn on sprinkler, unlock doors, call fire dept"
Event bus | Publishers, Subscribers | EventBus | Event routing, filtering, ordering

**Airport analogy (best for interviews):**

```
Without ATC:
Plane A talks to Plane B, C, D, E
Plane B talks to Plane A, C, D, E
(every plane must coordinate with every other plane)
= CHAOS

With ATC:
Plane A → ATC ← Plane B
Plane C → ATC ← Plane D
(every plane talks only to ATC)
ATC decides landing order, runway, timing
= ORDER
```

**Java/JDK usage:**

- `java.util.Timer` — mediates between TimerTasks and the scheduling thread
- `java.util.concurrent.Executor` — mediates between task submitters and worker threads
- `java.lang.reflect.Method` — mediates method invocation
- **Spring's ApplicationContext / EventBus** — mediates between beans:

```java
// Spring event publishing — mediator pattern
@Component
class OrderService {
    @Autowired
    private ApplicationEventPublisher publisher;  // mediator

    void placeOrder(Order order) {
        // OrderService does NOT know about InventoryService, EmailService, etc.
        publisher.publishEvent(new OrderPlacedEvent(order));
        // Mediator (Spring) routes to all listeners
    }
}

@Component
class InventoryService {
    @EventListener
    void onOrderPlaced(OrderPlacedEvent event) {
        // reduce stock — InventoryService does NOT know about OrderService
    }
}

@Component
class EmailService {
    @EventListener
    void onOrderPlaced(OrderPlacedEvent event) {
        // send confirmation — EmailService does NOT know about OrderService
    }
}
```

**Design Principle:** Loose Coupling — OrderService, InventoryService, EmailService know NOTHING about each other. They only know the mediator (ApplicationContext).

## Design Principles Summary for Mediator

Principle | How Mediator applies it
-- | --
SRP | Colleagues handle their own behavior. Mediator handles all communication/coordination logic.
OCP | Add new colleagues without modifying existing colleagues or the mediator's core interface.
DIP | Colleagues depend on the Mediator interface, not on each other's concrete classes.
Law of Demeter | Colleagues only talk to one friend (the mediator), never to other colleagues directly.
Loose Coupling | Colleagues are decoupled from each other. Only coupled to mediator.
DRY | Communication rules written once in mediator, not duplicated in every colleague.
Separation of Concerns | Business behavior in colleagues. Routing/coordination in mediator.

## Comparison with Other Patterns

### Mediator vs Observer

```
BOTH decouple objects. But differently:

Observer: ONE subject notifies MANY observers. One-to-many.
          Subject knows nothing about what observers do.
          No central coordination logic.

Mediator: MANY colleagues communicate through ONE mediator. Many-to-many.
          Mediator contains routing LOGIC and RULES.
          Mediator actively decides who gets what.

Observer: "Something happened, whoever cares can react"
Mediator: "Something happened, I decide who should know and how"
```

**Design Principle distinction:**
- Observer applies Hollywood Principle ("don't call us, we'll call you")
- Mediator applies Law of Demeter ("talk only to your mediator")

### Mediator vs Facade

```
Facade: ONE-WAY. Client → Facade → Subsystem.
        Subsystem objects don't know about the Facade.
        Facade simplifies ACCESS.

Mediator: TWO-WAY. Colleague ↔ Mediator ↔ Colleague.
          Colleagues know the mediator and communicate through it.
          Mediator controls COMMUNICATION.
```

```
FACADE (one-way simplification):
Client → Facade → [A, B, C, D]
                   (A, B, C, D don't know about Facade)

MEDIATOR (two-way coordination):
A ↔ Mediator ↔ B
C ↔ Mediator ↔ D
    (all know Mediator, Mediator knows all)
```

### Mediator vs Command

```
Command: wraps a REQUEST as an object (invoker → command → receiver)
Mediator: routes COMMUNICATION between peers (colleague → mediator → colleague)

Command: about storing/undoing individual actions
Mediator: about coordinating interactions between objects

They can work together: Mediator can route Commands between objects.
```

### Mediator vs Bridge

```
Bridge: separates TWO independent hierarchies (abstraction ↔ implementation)
Mediator: centralizes communication between MANY peers

Bridge: about structure — preventing class explosion
Mediator: about behavior — preventing communication spaghetti
```

### Mediator vs State

```
State: ONE object changes behavior based on internal state
Mediator: MANY objects interact through a central coordinator

State: internal behavior variation
Mediator: external communication coordination
```

## Mediator Can Become a God Object — Warning

The mediator centralizes all communication logic. If the system grows, the mediator can become huge:

Problem | Sign | Solution
-- | -- | --
Too many rules in one mediator | Mediator class is 1000+ lines | Split into sub-mediators or use Observer for simple broadcasts
Mediator knows too much | Mediator handles business logic, not just routing | Keep mediator focused on coordination only
Mediator becomes bottleneck | All communication funneled through one object | Use multiple mediators for different domains

**Design Principle:** SRP applies to the mediator itself. If it does too much, split it.

## The Progression Story (for interviews)

Step | What happens | Problem | Principle violated
-- | -- | -- | --
1 | 2-3 objects communicate directly | Works fine | —
2 | 5-6 objects, each knows all others | 30 connections, tight coupling | Law of Demeter
3 | Add a new object | Must update every existing object | OCP
4 | Communication rules (block, mute) added | Rules duplicated in every object | SRP, DRY
5 | Use Mediator: central coordinator, objects only know mediator | Add object = 1 connection. Rules in one place. | All principles restored

## How to Identify When to Use Mediator

Checklist:
- Multiple objects communicate with each other directly? Yes
- Adding a new object requires updating many existing objects? Yes
- Communication rules exist (routing, filtering, blocking)? Yes
- Objects are tightly coupled through each other? Yes

If yes → Mediator is a good fit.

## Quick Reference

Question | Answer | Design Principle
-- | -- | --
What problem does it solve? | Many-to-many direct dependencies between objects | Law of Demeter
What is the mediator? | Central object that routes all communication | SRP — coordination in one place
What are colleagues? | Objects that interact through the mediator instead of directly | Loose Coupling
Who knows whom? | Colleagues know only the mediator. Mediator knows all colleagues. | DIP
Can colleagues talk directly? | No. All communication goes through the mediator. | Law of Demeter
Where do communication rules live? | Only in the mediator | SRP, DRY
How is it different from Observer? | Observer = one-to-many notification. Mediator = many-to-many coordination with routing logic. | —
How is it different from Facade? | Facade = one-way access simplification. Mediator = two-way communication coordination. | —
Warning? | Mediator can become a God Object if it accumulates too much logic | SRP applies to mediator too
Java example | Spring ApplicationContext/EventBus, ATC for airplanes | —
Interview one-liner | Mediator pattern centralizes communication between many objects through one coordinator, replacing many-to-many direct dependencies with one-to-many dependencies on the mediator, keeping colleagues decoupled from each other. | Law of Demeter, SRP, DIP
