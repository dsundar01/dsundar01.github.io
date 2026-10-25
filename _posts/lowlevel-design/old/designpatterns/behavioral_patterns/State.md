# State Pattern

## CAUSE and EFFECT

```
CAUSE (the technique):
"Encapsulate state-specific behavior into separate state objects
and delegate behavior to the current state object"

EFFECT (the benefit):
"Eliminates large if/else or switch blocks that check the current
state before deciding what to do"
```

## The Problem in Normal Code

Suppose you build a **vending machine**.

```java
class VendingMachine {
    private String state = "IDLE";
    private int balance = 0;

    void insertCoin(int amount) {
        if (state.equals("IDLE")) {
            balance += amount;
            state = "HAS_MONEY";
            System.out.println("Coin inserted. Balance: " + balance);
        } else if (state.equals("HAS_MONEY")) {
            balance += amount;
            System.out.println("More coin inserted. Balance: " + balance);
        } else if (state.equals("DISPENSING")) {
            System.out.println("Please wait, dispensing in progress");
        } else if (state.equals("OUT_OF_STOCK")) {
            System.out.println("Machine is out of stock. Returning coin.");
        }
    }

    void selectProduct(String product) {
        if (state.equals("IDLE")) {
            System.out.println("Insert coin first");
        } else if (state.equals("HAS_MONEY")) {
            if (balance >= 100) {
                System.out.println("Dispensing " + product);
                state = "DISPENSING";
                dispense();
            } else {
                System.out.println("Not enough money");
            }
        } else if (state.equals("DISPENSING")) {
            System.out.println("Already dispensing");
        } else if (state.equals("OUT_OF_STOCK")) {
            System.out.println("Out of stock");
        }
    }

    void dispense() {
        if (state.equals("DISPENSING")) {
            System.out.println("Product dispensed");
            balance = 0;
            state = "IDLE";
        }
        // other states...
    }

    void refund() {
        if (state.equals("IDLE")) {
            System.out.println("Nothing to refund");
        } else if (state.equals("HAS_MONEY")) {
            System.out.println("Refunding " + balance);
            balance = 0;
            state = "IDLE";
        } else if (state.equals("DISPENSING")) {
            System.out.println("Cannot refund during dispensing");
        } else if (state.equals("OUT_OF_STOCK")) {
            System.out.println("Refunding " + balance);
            balance = 0;
            state = "IDLE";
        }
    }
}
```

**What goes wrong:**

- Every method has the SAME if/else checking all states
- 4 states x 4 methods = 16 branches in one class
- Add a new state (e.g., `MAINTENANCE`)? You must add a branch to EVERY method
- Add a new method (e.g., `cancel()`)? You must handle ALL states in it
- State transition logic is scattered everywhere
- Class grows into a massive unmaintainable blob
- Easy to forget a state in one method → bugs

## The Growth Problem

States | Methods | Branches
-- | -- | --
4 | 4 | 16
6 | 5 | 30
8 | 6 | 48
10 | 7 | 70

Every new state adds one branch to EVERY method. Every new method adds one branch per state. Growth is multiplicative.

## Three Approaches

**AP1:** Use if/else or switch on a state variable — works initially but becomes a giant mess as states and methods grow.

**AP2:** Use enums with behavior — slightly better but still concentrates all logic in one place.

**AP3:** Use State pattern — each state becomes its own class with its own behavior. The main object delegates to the current state.

## The Key Insight

Instead of the vending machine asking "what state am I in?" before every action, each state knows how to handle every action itself. The vending machine just says "current state, handle this."

```
Without State:
VendingMachine.insertCoin() {
    if (state == IDLE) { ... }
    if (state == HAS_MONEY) { ... }
    if (state == DISPENSING) { ... }
    if (state == OUT_OF_STOCK) { ... }
}

With State:
VendingMachine.insertCoin() {
    currentState.insertCoin();  // state object handles it
}
```

## The Pattern Structure

```
VendingMachine (Context)
  |
  | holds reference to current state
  v
VendingMachineState (interface)
  insertCoin()
  selectProduct()
  dispense()
  refund()
      |
  ____________________
  |        |         |          |
IdleState  HasMoney  Dispensing  OutOfStock
           State     State      State

Each state class implements ALL methods
with behavior specific to THAT state.
```

## Implementation

### Step 1: State interface

```java
interface VendingMachineState {
    void insertCoin(int amount);
    void selectProduct(String product);
    void dispense();
    void refund();
}
```

### Step 2: Context — holds current state and delegates

```java
class VendingMachine {
    private VendingMachineState currentState;
    private int balance;
    private int stock;

    // State instances (shared, reusable)
    private final VendingMachineState idleState = new IdleState(this);
    private final VendingMachineState hasMoneyState = new HasMoneyState(this);
    private final VendingMachineState dispensingState = new DispensingState(this);
    private final VendingMachineState outOfStockState = new OutOfStockState(this);

    VendingMachine(int stock) {
        this.stock = stock;
        this.balance = 0;
        this.currentState = idleState;
    }

    // Delegate everything to current state — NO if/else
    void insertCoin(int amount) { currentState.insertCoin(amount); }
    void selectProduct(String product) { currentState.selectProduct(product); }
    void dispense() { currentState.dispense(); }
    void refund() { currentState.refund(); }

    // State transition — called BY state objects
    void setState(VendingMachineState state) { this.currentState = state; }

    // Getters for state objects
    VendingMachineState getIdleState() { return idleState; }
    VendingMachineState getHasMoneyState() { return hasMoneyState; }
    VendingMachineState getDispensingState() { return dispensingState; }
    VendingMachineState getOutOfStockState() { return outOfStockState; }

    // Balance and stock management
    int getBalance() { return balance; }
    void setBalance(int balance) { this.balance = balance; }
    int getStock() { return stock; }
    void setStock(int stock) { this.stock = stock; }
}
```

### Step 3: State classes — each handles behavior for its own state

**IdleState:**

```java
class IdleState implements VendingMachineState {
    private VendingMachine machine;

    IdleState(VendingMachine machine) { this.machine = machine; }

    public void insertCoin(int amount) {
        machine.setBalance(machine.getBalance() + amount);
        System.out.println("Coin inserted. Balance: " + machine.getBalance());
        machine.setState(machine.getHasMoneyState());
    }

    public void selectProduct(String product) {
        System.out.println("Insert coin first");
    }

    public void dispense() {
        System.out.println("Insert coin and select product first");
    }

    public void refund() {
        System.out.println("Nothing to refund");
    }
}
```

**HasMoneyState:**

```java
class HasMoneyState implements VendingMachineState {
    private VendingMachine machine;

    HasMoneyState(VendingMachine machine) { this.machine = machine; }

    public void insertCoin(int amount) {
        machine.setBalance(machine.getBalance() + amount);
        System.out.println("More coin inserted. Balance: " + machine.getBalance());
    }

    public void selectProduct(String product) {
        if (machine.getBalance() >= 100) {
            System.out.println("Selected: " + product);
            machine.setState(machine.getDispensingState());
            machine.dispense();
        } else {
            System.out.println("Not enough money. Need 100, have " + machine.getBalance());
        }
    }

    public void dispense() {
        System.out.println("Select a product first");
    }

    public void refund() {
        System.out.println("Refunding " + machine.getBalance());
        machine.setBalance(0);
        machine.setState(machine.getIdleState());
    }
}
```

**DispensingState:**

```java
class DispensingState implements VendingMachineState {
    private VendingMachine machine;

    DispensingState(VendingMachine machine) { this.machine = machine; }

    public void insertCoin(int amount) {
        System.out.println("Please wait, dispensing in progress");
    }

    public void selectProduct(String product) {
        System.out.println("Already dispensing, please wait");
    }

    public void dispense() {
        System.out.println("Product dispensed!");
        machine.setBalance(machine.getBalance() - 100);
        machine.setStock(machine.getStock() - 1);

        if (machine.getStock() == 0) {
            machine.setState(machine.getOutOfStockState());
        } else if (machine.getBalance() > 0) {
            machine.setState(machine.getHasMoneyState());
        } else {
            machine.setState(machine.getIdleState());
        }
    }

    public void refund() {
        System.out.println("Cannot refund during dispensing");
    }
}
```

**OutOfStockState:**

```java
class OutOfStockState implements VendingMachineState {
    private VendingMachine machine;

    OutOfStockState(VendingMachine machine) { this.machine = machine; }

    public void insertCoin(int amount) {
        System.out.println("Machine is out of stock. Cannot accept coins.");
    }

    public void selectProduct(String product) {
        System.out.println("Out of stock");
    }

    public void dispense() {
        System.out.println("Out of stock");
    }

    public void refund() {
        if (machine.getBalance() > 0) {
            System.out.println("Refunding " + machine.getBalance());
            machine.setBalance(0);
        } else {
            System.out.println("Nothing to refund");
        }
        machine.setState(machine.getIdleState());
    }
}
```

### Step 4: Client code

```java
VendingMachine machine = new VendingMachine(2);

machine.insertCoin(50);           // "Coin inserted. Balance: 50"
machine.insertCoin(50);           // "More coin inserted. Balance: 100"
machine.selectProduct("Coke");    // "Selected: Coke" → "Product dispensed!"
machine.insertCoin(100);          // "Coin inserted. Balance: 100"
machine.selectProduct("Pepsi");   // "Selected: Pepsi" → "Product dispensed!"
machine.insertCoin(100);          // "Machine is out of stock. Cannot accept coins."
```

## Before vs After

**Before (without State):**

```java
void insertCoin(int amount) {
    if (state.equals("IDLE")) { ... }
    else if (state.equals("HAS_MONEY")) { ... }
    else if (state.equals("DISPENSING")) { ... }
    else if (state.equals("OUT_OF_STOCK")) { ... }
}
// same pattern for selectProduct(), dispense(), refund()
// 4 methods x 4 states = 16 branches in ONE class
```

**After (with State):**

```java
void insertCoin(int amount) {
    currentState.insertCoin(amount);  // one line. no branching.
}
// each state class has 4 methods
// 4 classes x 4 methods = 16 methods, but each is small and focused
```

## Where Do State Transitions Happen?

Inside the state objects themselves. Each state decides what the next state is.

```java
// Inside HasMoneyState.selectProduct():
machine.setState(machine.getDispensingState());  // transition to dispensing

// Inside DispensingState.dispense():
if (machine.getStock() == 0) {
    machine.setState(machine.getOutOfStockState());  // transition to out of stock
} else {
    machine.setState(machine.getIdleState());  // transition back to idle
}
```

State transition diagram:

```
                 insertCoin()
   ┌──────────────────────────────────┐
   v                                  |
 IDLE ──insertCoin()──> HAS_MONEY ──selectProduct()──> DISPENSING
   ^                      |                               |
   |                   refund()                      dispense()
   |                      |                               |
   └──────────────────────┘          stock > 0            |
   ^                                  |                   |
   └──────────────────────────────────┘                   |
                                                          |
                                          stock == 0      |
                                                          v
                                                    OUT_OF_STOCK
```

## Important: Who Triggers State Transitions?

Two approaches:

Approach | Where transitions live | Used when
-- | -- | --
State objects decide | Inside each state class (like our example) | When transitions depend on state-specific logic
Context decides | Inside the context (VendingMachine) | When transitions are simple and uniform

Our example uses the first approach — each state knows its own transitions. This is more common and more aligned with the pattern's intent.

## Real Examples

Example | Context | States
-- | -- | --
Vending machine | VendingMachine | Idle, HasMoney, Dispensing, OutOfStock
Document workflow | Document | Draft, Review, Approved, Published, Archived
Order processing | Order | Created, Paid, Shipped, Delivered, Returned, Cancelled
Media player | MediaPlayer | Stopped, Playing, Paused
Traffic light | TrafficLight | Red, Yellow, Green
TCP connection | TCPConnection | Listen, Established, Closed
Elevator | Elevator | Idle, MovingUp, MovingDown, DoorOpen

**Java/JDK usage:**

State pattern is not directly visible as a single JDK class, but the concept appears in:

- `Thread` states — NEW, RUNNABLE, BLOCKED, WAITING, TERMINATED (though Java implements this with enums internally, not the GoF State pattern)
- `javax.faces.lifecycle.Lifecycle` — JSF lifecycle phases
- Game engines, workflow engines, and parsers heavily use State pattern
- Spring State Machine — explicit state machine framework:

```java
// Spring State Machine example
builder.configureTransitions()
    .withExternal()
        .source(States.IDLE).target(States.HAS_MONEY)
        .event(Events.COIN_INSERTED)
    .and()
    .withExternal()
        .source(States.HAS_MONEY).target(States.DISPENSING)
        .event(Events.PRODUCT_SELECTED);
```

## Design Principles

Principle | How State uses it
-- | --
Single Responsibility | Each state class handles only its own behavior
Open/Closed | Add new states without modifying existing state classes or the context
Program to interface | Context depends on VendingMachineState interface, not concrete states
Encapsulation | State-specific behavior is encapsulated inside state objects, not scattered in conditionals
Liskov Substitution | All state objects are interchangeable through the common interface

## Comparison with Other Patterns

### State vs Strategy

```
STRUCTURALLY: Almost identical — both use composition to delegate
to an interface reference

INTENT:
State: object CHANGES its behavior when its internal state changes
       (transitions happen automatically as part of the workflow)
Strategy: client CHOOSES which algorithm to use
          (selection is made externally, usually once)

State: state objects know about each other and trigger transitions
Strategy: strategies don't know about each other

State: "I behave differently depending on what happened before"
Strategy: "I behave differently depending on what the client picked"
```

```
STATE (automatic transitions):
VendingMachine
  currentState: IdleState → HasMoneyState → DispensingState → IdleState
  (state changes itself based on actions)

STRATEGY (client picks once):
PaymentProcessor
  strategy: CardPayment  (client chose this, it stays)
```

### State vs Command

```
State: encapsulates WHAT to do based on current state
Command: encapsulates a REQUEST as an object

State: behavior changes over time as state transitions
Command: each command is independent, no state dependency
```

### State vs Bridge

```
State: ONE dimension varies over TIME (current state changes)
Bridge: TWO+ dimensions vary INDEPENDENTLY (composed at creation)

State solves: state-dependent branching
Bridge solves: class explosion from multiple dimensions
```

### State vs Composite

```
State: flat — one active state at a time
Composite: tree — nested hierarchy of objects

No structural similarity. Different problems entirely.
```

## The Progression Story (for interviews)

Step | What happens | Problem
-- | -- | --
1 | Object has 2-3 states | Simple if/else works
2 | States grow to 5-6 | Every method has a large if/else block
3 | New state added | Must touch every method in the class
4 | New method added | Must handle every state in the new method
5 | Use State: each state is its own class, context delegates | Adding a state = adding one class. Existing code untouched.

## How to Identify When to Use State

Checklist:
- Object behavior changes based on internal state? Yes
- Multiple methods have the same if/else checking state? Yes
- State transitions follow defined rules? Yes
- New states are likely to be added? Yes

If all four are yes → State pattern is a good fit.

## Quick Reference

Question | Answer
-- | --
What problem does it solve? | Eliminates large state-dependent if/else blocks scattered across methods
What is the context? | The main object whose behavior changes (VendingMachine)
What is the state interface? | Common interface all states implement (VendingMachineState)
What are concrete states? | Classes that implement state-specific behavior (IdleState, HasMoneyState, etc.)
Who triggers state transitions? | Usually the state objects themselves, based on actions and conditions
Does the context have if/else? | No. It delegates everything to currentState.
Key rule | Each state class handles ALL methods for that one state. The context just delegates.
How is it different from Strategy? | State transitions happen automatically. Strategy is chosen by the client externally.
How is it different from Bridge? | State = one dimension varies over time. Bridge = two dimensions vary independently.
Java example | Spring State Machine, Thread states conceptually, workflow/order processing systems
Interview one-liner | State pattern encapsulates state-specific behavior into separate state objects so the main object delegates to the current state instead of using if/else branching, and states themselves trigger transitions.
