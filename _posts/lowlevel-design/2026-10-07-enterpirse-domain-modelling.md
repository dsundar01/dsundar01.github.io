---
title: "Enterpirse Domain Modelling"
date: 2026-10-07 11:09:21 +05:30
categories: [LLD, Domain Modeling]
tags: [mustknow]
---


# Understanding Domain Models in a Natural Way

Before learning about Entities, Aggregates, Repositories, or Domain Events, we must first answer a more fundamental question:

> What exactly is a Domain Model?

Because every other DDD concept exists to support the Domain Model.

If you misunderstand the Domain Model:

```text
Entities become database tables.
Aggregates become meaningless wrappers.
Repositories become DAOs.
Domain Services become giant utility classes.
```

Understanding the Domain Model is the foundation of everything else.

---

# Think About Google Maps

Imagine you open Google Maps.

You see:

```text
Roads
Cities
Rivers
Airports
```

But you do NOT see:

```text
Water pipes
Electrical wiring
Internet cables
Building foundations
```

Why?

Because a map is not a copy of reality.

A map is:

> A simplified representation of the parts that matter for a specific purpose.

---

# A Domain Model Is Also a Map

A Domain Model is:

> A map of the business.

Not a copy of the database.

Not a copy of the API.

Not a copy of the UI.

Instead, it models:

```text
Business concepts
Business rules
Business language
```

---

# Example: Online Store

The business talks about:

```text
Customer
Order
Product
Shipment
Payment
```

So our model contains:

```java
Customer
Order
Product
Shipment
Payment
```

The business says:

```text
An order cannot ship before it is confirmed.
```

Therefore the model contains:

```java
order.ship();
```

with validation.

The code and the business speak the same language.

---

# What A Domain Model Is NOT

Many developers accidentally create a model of the database.

Example:

```java
@Entity
@Table(name="orders")
class OrderEntity {

    @Id
    Long id;

    @Column
    String status;
}
```

This tells us:

```text
Table Name
Column Name
Primary Key
```

But tells us nothing about:

```text
Can an Order ship?
Can it be cancelled?
What are the business rules?
```

This is primarily a database model.

Not a business model.

---

# Problem 1: The Data Bag

A very common design looks like this.

```java
public class Account {

    private Money balance;

    public Money getBalance() {
        return balance;
    }

    public void setBalance(Money balance) {
        this.balance = balance;
    }
}
```

This object contains:

```text
Data
```

but no:

```text
Behavior
Rules
Validation
```

It is simply a bag of fields.

---

# Where Do The Rules Go?

The rules end up in services.

```java
public class TransferService {

    public void transfer(
            Account from,
            Account to,
            Money amount
    ) {

        if(from.getBalance()
                .compareTo(amount) < 0) {
            throw new RuntimeException();
        }

        from.setBalance(
                from.getBalance()
                        .minus(amount)
        );
    }
}
```

Now the service knows everything.

The Account knows nothing.

---

# Why Is This Bad?

Suppose another developer writes:

```java
account.setBalance(
        Money.of(-500)
);
```

Nothing stops them.

The Account can become:

```text
Balance = -500
```

which violates the business rule.

The object cannot protect itself.

---

# Problem 2: The Framework Object

Another common design:

```java
@Entity
@Table(name="orders")
public class Order {

    @Column
    private String status;

    @OneToMany
    private List<OrderLine> lines;
}
```

Eventually business logic gets mixed with:

```text
Hibernate
JPA
Database concerns
Lazy Loading
Mappings
```

The object becomes difficult to reason about.

---

# The Root Cause

In both failures:

```text
The business does not own the model.
```

Instead the model is owned by:

```text
Database
Framework
Service Layer
```

The business rules have no permanent home.

---

# What Makes A Good Domain Model?

A proper Domain Model has three important properties.

---

# Property 1: It Speaks Business Language

Developers often use technical language.

Example:

```java
setStatus("S")
```

What does:

```text
S
```

mean?

Nobody knows.

---

A Domain Model uses business language.

```java
order.submit();
order.ship();
shipment.delay();
customer.blacklist();
```

Now the code reads like a business conversation.

---

# Business Conversation

A Product Owner says:

```text
An order cannot ship
before confirmation.
```

The code becomes:

```java
public void ship() {

    if(status != CONFIRMED) {
        throw new IllegalStateException();
    }

    status = SHIPPED;
}
```

The sentence and the code match.

That is the goal.

---

# Property 2: It Holds The Invariants

An invariant is:

> A business truth that must always remain true.

Examples:

```text
Balance can never go negative.

A shipped order cannot be cancelled.

A blacklisted customer
cannot place orders.
```

---

Bad approach:

```java
if(customer.isBlacklisted()) {
}
```

inside controllers.

Every caller must remember the rule.

---

Better approach:

```java
public void requireEligible() {

    if(blacklisted) {
        throw new CustomerBlockedException();
    }
}
```

Now the Customer protects itself.

Nobody can forget the rule.

---

# Property 3: Persistence Ignorance

The Domain Model should not care how data is stored.

The Order should think about:

```text
Orders
Customers
Payments
```

Not:

```text
SQL
Hibernate
PostgreSQL
@Table
@Column
```

---

Bad:

```java
@Entity
@Table(name="orders")
class Order {
}
```

Domain depends on database.

---

Good:

```java
public class Order {

    public void submit() {

    }
}
```

Plain Java.

Business-focused.

---

# Why Persistence Ignorance Matters

Suppose you write a test.

```java
@Test
void shouldRejectEmptyOrder() {

    Order order = new Order();

    assertThrows(
        Exception.class,
        order::submit
    );
}
```

If Order depends on:

```text
Database
Hibernate
Transactions
```

The test becomes difficult.

If Order is plain Java:

```text
Test runs instantly.
```

---

# The Domain Model Boundary

The Domain Model sits at the center.

```text
                 Controller
                      |
                      v
Repository --> Domain Model <-- DTO Mapper
                      ^
                      |
                  Database
```

The important rule:

```text
Everything may depend on the Domain Model.

The Domain Model depends on nothing.
```

---

# Example Architecture

```text
Domain
------
Order
Customer
Money
Shipment
```

```text
Infrastructure
--------------
JpaOrderRepository
Hibernate Config
Database
```

```text
API
---
OrderController
OrderRequest
OrderResponse
```

Only the outer layers know about the domain.

The domain knows nothing about them.

---

# Easy Way To Remember

Think of the Domain Model as:

```text
The brain of the system.
```

The database is:

```text
Memory.
```

The API is:

```text
The mouth.
```

The controller is:

```text
The receptionist.
```

The business rules belong in:

```text
The brain.
```

Not in the mouth.

Not in memory.

Not at the reception desk.

---

# Strong Online Store Example

Business says:

```text
An order cannot ship
before confirmation.
```

Wrong Design:

```java
controller.shipOrder();
```

checks it.

```java
batchJob.shipOrder();
```

checks it.

```java
importJob.shipOrder();
```

checks it.

Someone forgets.

Rule broken.

---

Correct Design:

```java
public class Order {

    public void ship() {

        if(status != CONFIRMED) {
            throw new IllegalStateException();
        }

        status = SHIPPED;
    }
}
```

Everybody calls:

```java
order.ship();
```

The Order owns the rule.

The rule cannot be bypassed.

---

# Quick Comparison

| Bad Model                      | Good Domain Model           |
| ------------------------------ | --------------------------- |
| Speaks database language       | Speaks business language    |
| Getters and setters everywhere | Business operations         |
| Rules in controllers/services  | Rules inside domain objects |
| Depends on framework           | Framework independent       |
| Hard to test                   | Easy to test                |
| Data-centric                   | Business-centric            |

---

# One-Line Summary

A Domain Model is a business-focused representation of the problem domain. It speaks the language of the business, owns the business rules and invariants, remains independent of databases and frameworks, and acts as the central place where the system's most important behavior lives.

## Identifying Entities and Value Objects

### Introduction

- `Every domain model is made of two kinds of objects`, and the difference between them drives more design decisions than any other single distinction in this chapter. - The two kinds are `entities and value object`.
- An entity has identity. It is the same thing over time even when its contents change. An order is the same order at confirmed, shipped, and delivered, `even though its status field changes, because it has an identity that outlives any particular value of its fields.`
- A value object does not. A money amount of `fifty dollars is not the same object as a different fifty dollars`; they are interchangeable, because only the contents matter.

### Problem Statement

Many codebases model every domain object as an **Entity**. This creates unnecessary complexity and causes problems in four main areas:

1. Equality
2. Mutability
3. Persistence
4. Domain logic

Some domain objects should instead be modeled as **Value Objects**.

## Entity and Value Object

### Entity

An **Entity**:

- Has a unique identity, usually represented by an `id`.
- Is identified by its identity rather than its field values.
- Can have the same field values as another entity while still being a different object.

Common examples:

- `Customer`
- `Order`
- `Invoice`
- `Employee`
- `Product`

```java
Customer customer1 = new Customer(1L, "John");
Customer customer2 = new Customer(1L, "John");

customer1.equals(customer2); // true because they have the same identity

```

### Value Object

A **Value Object**:

- Does not require a unique identity.
- Is defined entirely by its field values.
- Should usually be immutable.
- Uses value-based equality.

Common examples:

- `Address`
- `Money`
- `Quantity`
- `EmailAddress`
- `PhoneNumber`
- `DateRange`
- `Percentage`

```java
Address address1 = new Address("Main Street", "New York");
Address address2 = new Address("Main Street", "New York");

address1.equals(address2); // true because the values are the same

```

---

## 1. Equality Problems

When everything is modeled as an Entity, equality is often based on object identity or database identity.

```java
Address address1 = new Address("Main Street", "New York");
Address address2 = new Address("Main Street", "New York");

System.out.println(address1 == address2); // false

```

Although both addresses contain the same information, they are different objects in memory.

This can cause comparisons such as the following to fail:

```java
invoice.getAddress().equals(customer.getAddress());

```

The business requirement is usually:

> Do these addresses represent the same location?

It is not:

> Are these variables pointing to the exact same object in memory?

If two objects should be considered equal when their values are equal, they are likely **Value Objects**.

### Better Approach

Implement value-based equality or use a Java `record`.

```java
public record Address(
    String street,
    String city
) {
}

```

Java records automatically provide value-based implementations of:

- `equals()`
- `hashCode()`
- `toString()`

```java
Address address1 = new Address("Main Street", "New York");
Address address2 = new Address("Main Street", "New York");

System.out.println(address1.equals(address2)); // true

```

---

## 2. Mutability Problems

Suppose the same mutable `Address` object is shared by a customer, an invoice, and a shipment.

```java
Address address = new Address("Main Street");

customer.setAddress(address);
invoice.setAddress(address);
shipment.setAddress(address);

```

If one code path changes the address:

```java
address.setStreet("Park Street");

```

All three objects now contain the modified address:

```text
Customer -> Park Street
Invoice  -> Park Street
Shipment -> Park Street

```

This happens because all three objects reference the same mutable `Address` instance.

As a result, one innocent-looking setter call can silently modify multiple business objects.

### Better Approach

Make the Value Object immutable.

```java
public record Address(
    String street,
    String city
) {
}

```

To change an address, create a new instance:

```java
Address oldAddress = new Address("Main Street", "New York");

Address newAddress = new Address("Park Street", "New York");

```

The original address remains unchanged.

This is especially important for historical documents such as invoices and shipments. Changing a customer's current address should not automatically modify the address stored on an older invoice.

---

## 3. Persistence Problems

Entities usually require:

- A table
- A primary key
- An identifier
- Entity lifecycle management
- Relationships with other entities

If every domain concept is modeled as an Entity, even simple values receive separate tables.

For example:

```text
ADDRESS
-------
id
street
city

MONEY
-----
id
amount
currency

```

The database may eventually contain many small tables whose main purpose is to provide IDs for objects that do not require independent identities.

The schema then starts representing the ORM's requirements instead of the business domain.

### Better Approach

A Value Object can often be stored as part of its owning Entity.

For example:

```text
CUSTOMER
--------
id
name
street
city

```

In JPA, an `Address` can be modeled as an embeddable object.

```java
@Embeddable
public class Address {

    private String street;
    private String city;

    protected Address() {
    }

    public Address(String street, String city) {
        this.street = street;
        this.city = city;
    }

    public String getStreet() {
        return street;
    }

    public String getCity() {
        return city;
    }
}

```

The owning Entity can embed it:

```java
@Entity
public class Customer {

    @Id
    private Long id;

    private String name;

    @Embedded
    private Address address;
}

```

The address fields can then be stored in the `customer` table without creating a separate `address` table or address ID.

## 4. Unsafe Domain Logic

Consider a price represented as a mutable Entity.

```java
Money price = new Money(100);

price.setAmount(10);

```

Any object holding the same `Money` reference now sees the modified amount.

This makes business logic unreliable because values such as the following are expected to remain stable:

- Price
- Total
- Tax rate
- Quantity
- Discount
- Percentage

An accidental setter call can change calculations without making the impact obvious.

### Better Approach

Model `Money` as an immutable Value Object.

```java
import java.math.BigDecimal;
import java.util.Objects;

public record Money(
    BigDecimal amount,
    String currency
) {
    public Money {
        Objects.requireNonNull(amount, "Amount cannot be null");
        Objects.requireNonNull(currency, "Currency cannot be null");

        if (amount.signum() < 0) {
            throw new IllegalArgumentException(
                "Amount cannot be negative"
            );
        }
    }
}

```

Instead of modifying the existing value, return a new one.

```java
public Money add(Money other) {
    if (!currency.equals(other.currency())) {
        throw new IllegalArgumentException(
            "Cannot add amounts with different currencies"
        );
    }

    return new Money(
        amount.add(other.amount()),
        currency
    );
}

```

Usage:

```java
Money price = new Money(
    new BigDecimal("100.00"),
    "USD"
);

Money tax = new Money(
    new BigDecimal("10.00"),
    "USD"
);

Money total = price.add(tax);

```

The original `price` and `tax` values remain unchanged.

## Summary of the Problems

| Problem             | Cause                                     | Result                                                        |
| ------------------- | ----------------------------------------- | ------------------------------------------------------------- |
| Equality issues     | Objects are compared using identity       | Two objects with identical values may be treated as different |
| Mutation bugs       | Value-like objects are mutable and shared | One change unexpectedly affects multiple objects              |
| Database complexity | Every object receives a table and ID      | The schema becomes unnecessarily complicated                  |
| Unsafe domain logic | Important values can be modified          | Calculations and business rules become unreliable             |

## When to Use an Entity

Use an **Entity** when the object has a unique identity that must be tracked over time.

Examples:

```text
Customer
Order
Invoice
Employee
Product

```

Two customers with the same name and address may still be different customers.

```java
Customer customer1 = new Customer(
    101L,
    "John Smith"
);

Customer customer2 = new Customer(
    102L,
    "John Smith"
);

```

Although the data looks similar, the customers have different identities.

## When to Use a Value Object

Use a **Value Object** when an object is defined entirely by its values.

Examples:

```text
Address
Money
Quantity
EmailAddress
PhoneNumber
DateRange
Percentage

```

Two addresses containing the same values should normally be considered equal.

```java
Address address1 = new Address(
    "Main Street",
    "New York"
);

Address address2 = new Address(
    "Main Street",
    "New York"
);

address1.equals(address2); // true

```

## Rule of Thumb

Ask the following question:

> If two objects contain exactly the same data, should they be considered the same thing?

- If the answer is **yes**, use a **Value Object**.
- If the answer is **no**, use an **Entity**.

### Example: Address

Two addresses with the same street and city normally represent the same value.

```text
Address -> Value Object

```

### Example: Customer

Two customers can have the same name and address but still represent different people.

```text
Customer -> Entity

```

## Key Takeaway

Do not model every domain object as an Entity.

Use Entities for objects that require identity and lifecycle tracking. Use Value Objects for concepts that are defined by their values.

Properly designed Value Objects provide:

- Value-based equality
- Immutability
- Safer domain logic
- Simpler persistence
- Clearer domain models
- Fewer unintended side effects

# Understanding Aggregates in a Natural Way

Before talking about aggregates, let's start with a simple question:

> When multiple objects together must always follow a business rule, who is responsible for enforcing that rule?

That is exactly the problem aggregates solve.

---

## Imagine an Online Shopping System

Suppose you have:

```java
Order
OrderLine
Customer
Product
```

An order contains multiple order lines.

For example:

```text
Order #1001

- Laptop     x 1  = $1000
- Mouse      x 2  = $40

Total = $1040
```

The `Order` and its `OrderLine` objects are closely related.

Some business rules could be:

- An order must have at least one line.
- An empty order cannot be submitted.
- A submitted order cannot be modified.
- The order total must equal the sum of all order lines.

These rules involve both the `Order` and its `OrderLine` objects.

---

## The Problem Without Aggregates

A beginner's design might look like this:

```text
Order
 ├── List<OrderLine>
 └── Customer

OrderLine
 └── Product
```

Every object may be freely accessible and independently mutable.

```java
Order order = repository.findById(id);

OrderLine line = order.getLines().get(0);

line.setQuantity(0);
```

This looks harmless, but it can break important business rules.

### Rule Violation 1: Invalid Order Line

Suppose the order has only one line.

Before the update:

```text
Order
 └── Laptop x 1
```

After the update:

```text
Order
 └── Laptop x 0
```

The order now effectively contains no valid item, but nobody checked the following rule:

> An order must contain at least one valid item.

The rule has been broken silently.

### Rule Violation 2: Incorrect Total

Suppose the quantity changes from two to one.

Before:

```text
Laptop x 2 = $2000
```

After:

```text
Laptop x 1 = $1000
```

Did the order total update?

Maybe it did, or maybe the developer forgot to update it. The model itself does not guarantee consistency.

### The Real Problem

Every object is independently mutable:

```text
Service A changes Order
Service B changes OrderLine
Service C changes Product
```

No single object controls the overall consistency.

The system works only if every developer remembers every business rule in every code path. That is fragile and difficult to maintain.

---

## What Is an Aggregate?

An **Aggregate** is a group of domain objects that must stay consistent together.

Think of it as a protective boundary around closely related objects.

```text
+-----------------------+
|   Order Aggregate     |
|                       |
|   Order               |
|   OrderLine           |
|   OrderLine           |
|   ShippingAddress     |
+-----------------------+
```

Everything inside the box belongs to the same consistency boundary.

In this example:

- `Order` is an Entity.
- `OrderLine` objects belong to the Order.
- `ShippingAddress` may be a Value Object.
- All of them must remain consistent together.

---

## What Is an Aggregate Root?

Every aggregate has one main object called the **Aggregate Root**.

For the Order Aggregate, the root is the `Order`.

```text
Outside World
      |
      v
    Order
   /  |  \
Line Line Address
```

The Aggregate Root is the only entry point into the aggregate.

Code outside the aggregate should not directly modify its internal objects. All changes should go through the root.

### Good

```java
order.addLine(productId, quantity, price);
order.changeQuantity(lineId, newQuantity);
order.submit();
```

### Bad

```java
orderLine.setQuantity(0);
orderLine.setPrice(newPrice);
```

The bad version allows callers to bypass the Order's business rules.

---

## A Real-Life Analogy

Think of the Aggregate Root as a manager.

Without a manager, everyone can directly change sensitive information:

```text
Employee
   |
   v
Payroll System
```

That can lead to inconsistent or unauthorized changes.

With a manager:

```text
Employee
   |
   v
Manager
   |
   v
Payroll System
```

The manager checks the rules before allowing a change.

An aggregate works similarly:

```text
Application
    |
    v
  Order
    |
    v
OrderLine
```

The application requests a change through `Order`, and `Order` decides whether the change is valid.

---

## How the Aggregate Root Protects Business Rules

Instead of changing a line directly:

```java
line.setQuantity(5);
```

Ask the Order to change it:

```java
order.changeQuantity(lineId, Quantity.of(5));
```

The Order can validate the request before making the change.

```java
public void changeQuantity(
        LineId lineId,
        Quantity quantity
) {
    if (status != OrderStatus.DRAFT) {
        throw new IllegalStateException(
            "Cannot modify a submitted order"
        );
    }

    if (quantity.isZero()) {
        throw new IllegalArgumentException(
            "Quantity must be greater than zero"
        );
    }

    OrderLine line = findLine(lineId);
    line.changeQuantity(quantity);
}
```

Now callers cannot bypass these rules.

---

## Three Important Properties of an Aggregate

### 1. It Has One Root

Only the Aggregate Root should be used by the outside world.

For the Order Aggregate:

```text
Aggregate Root = Order
```

The outside world interacts with the root:

```java
order.addLine(productId, quantity, price);
order.removeLine(lineId);
order.submit();
```

It should not directly manipulate internal `OrderLine` objects.

---

### 2. It Protects Invariants

An **invariant** is a business rule that must always remain true.

Examples:

- An order cannot be empty when submitted.
- A submitted order cannot be changed.
- Quantity must be greater than zero.
- The total must equal the sum of all line subtotals.

The Aggregate Root protects these invariants.

```java
public void submit() {
    if (lines.isEmpty()) {
        throw new IllegalStateException(
            "Cannot submit an empty order"
        );
    }

    status = OrderStatus.SUBMITTED;
}
```

The rule is part of the domain model, so callers do not need to remember it.

---

### 3. It Changes as One Unit

Everything inside an aggregate should change together in one transaction.

For example:

```java
order.addLine(productId, quantity, price);
```

The operation may involve:

```text
Adding the OrderLine
Updating the Order
Recalculating the total
Validating the Order
```

These changes should either all succeed or all fail.

```text
All changes succeed
```

or:

```text
All changes are rolled back
```

The system should never save only half of the required change.

---

## Example of a Protected Order Aggregate

```java
public class Order {

    private final OrderId id;
    private final CustomerId customerId;
    private final List<OrderLine> lines = new ArrayList<>();
    private OrderStatus status = OrderStatus.DRAFT;

    public Order(OrderId id, CustomerId customerId) {
        this.id = id;
        this.customerId = customerId;
    }

    public void addLine(
            ProductId productId,
            Quantity quantity,
            Money price
    ) {
        if (status != OrderStatus.DRAFT) {
            throw new IllegalStateException(
                "Cannot add a line to a submitted order"
            );
        }

        lines.add(
            new OrderLine(productId, quantity, price)
        );
    }

    public Money total() {
        return lines.stream()
                .map(OrderLine::subtotal)
                .reduce(Money.zero(), Money::add);
    }

    public void submit() {
        if (lines.isEmpty()) {
            throw new IllegalStateException(
                "Cannot submit an empty order"
            );
        }

        status = OrderStatus.SUBMITTED;
    }
}
```

The important point is that `OrderLine` objects are created and controlled by `Order`.

The caller cannot directly add raw objects or bypass the Order's rules.

---

## How to Decide the Aggregate Boundary

The hardest part is deciding what belongs inside the aggregate.

Ask this question:

> Which objects must change together for the business rules to remain valid?

Objects that must remain consistent in the same transaction usually belong in the same aggregate.

### Order and OrderLine

They should normally be in the same aggregate because:

- The total depends on the lines.
- Order validity depends on the lines.
- Submission rules depend on the lines.
- Adding or removing a line changes the Order.

```text
Order + OrderLine = Same Aggregate
```

### Customer and Order

They should normally be separate aggregates.

A customer can change without changing an order:

```text
Customer changes phone number
Order remains unchanged
```

An order can also change without changing the customer:

```text
Order is submitted
Customer remains unchanged
```

Therefore:

```text
Customer Aggregate != Order Aggregate
```

### Product and Order

A Product also has its own lifecycle.

The product catalog price may change tomorrow, but an existing order should usually keep the price that was recorded when the line was added.

Therefore:

```text
Product Aggregate != Order Aggregate
```

---

## Start with Small Aggregates

A common mistake is creating one giant aggregate containing everything connected to a Customer.

```text
Customer
 ├── Orders
 │   ├── OrderLines
 │   ├── Products
 │   └── Payments
 ├── Addresses
 └── Invoices
```

This creates a very large object graph.

A small customer update could require loading or locking many unrelated objects.

A healthier design is usually:

```text
Customer Aggregate
Order Aggregate
Product Aggregate
Payment Aggregate
Invoice Aggregate
```

Each aggregate owns only the objects required to enforce its own rules.

A useful guideline is:

> Start with a small aggregate and expand it only when a real business invariant requires multiple objects to change together.

---

## Cross-Aggregate References

Separate aggregates still need to relate to each other.

For example:

- An Order belongs to a Customer.
- An OrderLine refers to a Product.

The typical rule is:

> Reference another aggregate by its ID, not by holding the full object.

### Avoid This

```java
public class Order {
    private Customer customer;
}
```

This directly connects the Order Aggregate to the complete Customer Aggregate.

The aggregates become tightly coupled, and loading an Order may also load a Customer and other connected objects.

### Prefer This

```java
public class Order {
    private CustomerId customerId;
}
```

An OrderLine can follow the same pattern:

```java
public class OrderLine {
    private ProductId productId;
    private Quantity quantity;
    private Money price;
}
```

If customer details are needed, load the Customer separately:

```java
Customer customer = customerRepository.findById(
    order.getCustomerId()
);
```

This keeps each aggregate independent.

---

## Final Aggregate Picture

```text
+--------------------------------+
|        Order Aggregate         |
|                                |
|  Order (Aggregate Root)        |
|      |                         |
|      +--- OrderLine            |
|      +--- OrderLine            |
|      +--- ShippingAddress      |
|                                |
+--------------------------------+
          |              |
          | CustomerId   | ProductId
          v              v
+------------------+  +------------------+
| Customer         |  | Product          |
| Aggregate        |  | Aggregate        |
|                  |  |                  |
| Customer (Root)  |  | Product (Root)   |
+------------------+  +------------------+
```

The `Order` is the only door into the Order Aggregate.

`OrderLine` and `ShippingAddress` are internal parts of the aggregate. Other aggregates are referenced only by their IDs.

---

## Easy Way to Remember

### Entity: Who am I?

An Entity has a unique identity.

Examples:

```text
Customer
Order
Product
```

Two customers with the same name are still different customers because they have different identities.

### Value Object: What am I?

A Value Object is defined by its values.

Examples:

```text
Money
Address
Quantity
```

Two `Money` objects with the same amount and currency represent the same value.

### Aggregate: What must stay consistent together?

An Aggregate groups objects that must obey business rules together.

Example:

```text
Order
 + OrderLines
 + ShippingAddress
```

### Aggregate Root: Who guards the rules?

The Aggregate Root is the only entry point and protects the aggregate's invariants.

Example:

```text
Order = Aggregate Root
```

---

## Quick Summary

| Concept        | Meaning                                            | Example                      |
| -------------- | -------------------------------------------------- | ---------------------------- |
| Entity         | An object with a unique identity                   | `Order`, `Customer`          |
| Value Object   | An object defined by its values                    | `Money`, `Quantity`          |
| Aggregate      | Objects that must stay consistent together         | `Order` and `OrderLine`      |
| Aggregate Root | The object that controls access and protects rules | `Order`                      |
| Invariant      | A rule that must always remain true                | Cannot submit an empty Order |

---

## One-Line Summary

An **Aggregate** is a small consistency boundary around related domain objects, and the **Aggregate Root** is the single entry point that ensures business rules cannot be bypassed.

# Understanding Domain Services in a Natural Way

Before learning Domain Services, let's start with a simple question:

> What happens when a business operation needs multiple aggregates to work together?

We learned earlier that:

- An Aggregate protects its own rules.
- An Aggregate Root controls all changes inside its boundary.
- Aggregates should not directly modify other aggregates.

But some business operations naturally involve **more than one aggregate**.

That's where **Domain Services** come in.

---

# Imagine a Banking System

Suppose we have two Account aggregates:

```text
Account A
Balance = $1000

Account B
Balance = $500
```

Now a customer wants to transfer:

```text
$200
from Account A
to Account B
```

---

## Question

Who should own this operation?

Should Account A handle it?

Should Account B handle it?

Or should some other object handle it?

---

# First Attempt: Put It Inside Account

Most developers initially write something like this:

```java
public class Account {

    private Money balance;

    public void transfer(
            Account target,
            Money amount
    ) {

        if(balance.compareTo(amount) < 0) {
            throw new InsufficientFundsException();
        }

        this.balance =
                this.balance.subtract(amount);

        target.balance =
                target.balance.add(amount);
    }
}
```

At first glance this looks reasonable.

```java
accountA.transfer(
    accountB,
    Money.of(200)
);
```

Simple.

Done.

---

# Why This Is Actually a Problem

Look carefully.

```java
target.balance =
        target.balance.add(amount);
```

Account A is directly changing Account B.

In other words:

```text
Account A
     |
     v
modifies
     |
     v
Account B
```

But we learned something important about aggregates:

> One aggregate should not reach inside another aggregate.

Each aggregate should manage its own state.

---

## Real-Life Analogy

Imagine one bank account could directly open another account's database record and modify its balance.

```text
Account A
   |
   v
Account B.balance = ...
```

That's dangerous.

Account B doesn't get a chance to validate anything.

It doesn't get a chance to enforce its own rules.

Its Aggregate Root is completely bypassed.

---

# Aggregate Boundaries Are Broken

Remember:

```text
Aggregate A
```

should not reach inside:

```text
Aggregate B
```

If it does, then aggregate boundaries exist only on paper.

They are not actually being respected.

---

# Second Attempt: Put Everything in Controller

Many teams move the logic to the application layer.

Example:

```java
@RestController
class TransferController {

    public void transfer() {

        // validate

        // load accounts

        // check balance

        // transfer money

        // save accounts
    }
}
```

Now the transaction works.

But a new problem appears.

---

# Business Logic Is in the Wrong Place

The controller now contains:

```text
Transfer rules
Withdrawal limits
Currency conversion
Fraud checks
Validation
```

Mixed together with:

```text
HTTP requests
JSON parsing
Database transactions
Security
```

Now domain rules are mixed with technical plumbing.

---

## Why Is This Bad?

Suppose tomorrow you need:

```text
Mobile App
Web App
Batch Job
API
```

All of them need money transfer.

You don't want the business rule hiding inside:

```java
TransferController
```

Business rules should live in the domain model.

---

# Both Solutions Fail

## Solution 1

Put transfer inside Account.

Problem:

```text
Crosses aggregate boundaries.
```

---

## Solution 2

Put transfer inside Controller.

Problem:

```text
Domain rules are mixed
with framework code.
```

---

# Enter Domain Service

A Domain Service exists for:

> Business operations that involve multiple aggregates but don't belong to any one aggregate.

Think of it as:

```text
An operation
not an object
```

---

# Example: Transfer Service

```java
class TransferService {

    private final AccountRepository accounts;

    public void transfer(
            AccountId from,
            AccountId to,
            Money amount
    ) {

        Account debit =
                accounts.find(from);

        Account credit =
                accounts.find(to);

        debit.withdraw(amount);
        credit.deposit(amount);
    }
}
```

Now the transfer operation has its own home.

---

# What Changed?

Before:

```java
accountA.transfer(accountB);
```

Account A controlled everything.

---

Now:

```java
transferService.transfer(
        sourceId,
        targetId,
        amount
);
```

The Domain Service coordinates.

Each account still protects itself.

---

# The Key Idea

The Domain Service handles:

```text
Coordination
Validation
Workflow
Orchestration
```

The Entity handles:

```text
Its own state
Its own rules
Its own integrity
```

---

# Each Aggregate Protects Itself

Account still owns account-specific rules.

Example:

```java
public void withdraw(
        Money amount
) {

    if(balance.compareTo(amount) < 0) {
        throw new InsufficientFundsException();
    }

    balance = balance.subtract(amount);
}
```

Account knows:

```text
Can I withdraw?
```

---

And deposit:

```java
public void deposit(
        Money amount
) {
    balance =
        balance.add(amount);
}
```

Account knows:

```text
How do I receive money?
```

---

But Account does NOT know:

```text
How do I transfer money
between two accounts?
```

Because that involves:

```text
Account A
+
Account B
```

which is beyond its boundary.

---

# Real-Life Analogy: Airport Flight

Imagine two airports.

```text
Bengaluru Airport
Delhi Airport
```

Question:

Who owns the flight?

```text
Airport A ?
Airport B ?
```

Neither.

The flight operation belongs to:

```text
Airline
```

The airline coordinates both airports.

---

Similarly:

```text
Account A
Account B
```

do not own:

```text
Transfer
```

The Domain Service owns it.

---

# The Deciding Test

This is the most important rule.

Ask:

> Is this rule about one object, or about multiple objects working together?

---

## Single Object Rule

Belongs inside the Entity.

Example:

```java
account.withdraw()
```

Only concerns one account.

---

```java
account.deposit()
```

Only concerns one account.

---

```java
account.isOverdrawn()
```

Only concerns one account.

---

```java
account.calculateDailyLimit()
```

Only concerns one account.

---

These belong on:

```text
Account Entity
```

---

## Multiple Object Rule

Belongs in a Domain Service.

Examples:

```java
transferMoney()
```

Involves:

```text
Account A
Account B
```

---

```java
matchDriverAndRide()
```

Involves:

```text
Driver
Ride Request
```

---

```java
checkCustomerBlacklist()
```

Involves:

```text
Customer
Blacklist
Order
```

---

```java
settleInvoice()
```

Involves:

```text
Invoice
Payment
Account
```

---

These belong in:

```text
Domain Service
```

---

# The Smell That Tells You a Service Is Needed

Suppose you see this:

```java
public void transfer(
        Account target
) {

    if(target.balance > ...)
}
```

Notice this line:

```java
target.balance
```

Immediately ask:

> Why am I looking inside another aggregate?

The moment an entity starts reaching into another entity's internals:

```java
other.balance
other.status
other.limit
other.items
```

you have likely crossed an aggregate boundary.

A Domain Service is probably needed.

---

# Don't Abuse Domain Services

After learning about Domain Services, many developers do this:

```java
Account
Customer
Order
```

become:

```java
private fields + getters + setters
```

All business rules move here:

```java
AccountService
CustomerService
OrderService
```

This is called an:

```text
Anemic Domain Model
```

---

# Why Is That Bad?

Your entities become:

```java
class Account {

    private Money balance;

    public Money getBalance() {
        return balance;
    }

    public void setBalance(
            Money balance
    ) {
        this.balance = balance;
    }
}
```

Nothing meaningful lives inside them.

They're just data containers.

---

Instead, entities should still contain their own behavior.

```java
account.withdraw();
account.deposit();
account.freeze();
account.unfreeze();
```

The entity should protect itself.

---

# Rule of Thumb

Most business rules should live in entities.

Examples:

```text
Account rules -> Account

Order rules -> Order

Customer rules -> Customer
```

Only a small number of rules belong in Domain Services.

Examples:

```text
Transfer money
Fraud check
Route calculation
Order settlement
```

---

# Naming Domain Services

Domain Services should be named using business language.

Good examples:

```java
TransferService
FraudCheckService
RouteCalculator
SettlementService
PricingService
```

Notice:

```text
These are actions
```

They represent things the business does.

---

# Domain Services Are Usually Stateless

A Domain Service usually does not own business data.

Example:

```java
class TransferService {

    public void transfer(...) {
    }
}
```

It coordinates work.

It does not represent something stored in the database.

---

Think of it as:

```text
Entity         = Noun
Value Object   = Description
Domain Service = Verb
```

Examples:

```text
Account            -> Noun
Order              -> Noun

Address            -> Description
Money              -> Description

TransferService    -> Verb
FraudCheckService  -> Verb
```

---

# Complete Example

```java
public class TransferService {

    private final AccountRepository accounts;

    public void transfer(
            AccountId from,
            AccountId to,
            Money amount
    ) {

        if(amount.isNegative()
                || amount.isZero()) {

            throw new IllegalArgumentException(
                    "Amount must be positive"
            );
        }

        Account debit =
                accounts.find(from);

        Account credit =
                accounts.find(to);

        debit.withdraw(amount);
        credit.deposit(amount);

        accounts.save(debit);
        accounts.save(credit);
    }
}
```

Notice the responsibilities.

### Domain Service

```text
Load Account A
Load Account B
Validate transfer
Coordinate transfer
Save results
```

### Account Entity

```text
Can withdraw?
Update balance
Prevent overdraft
Handle account-specific rules
```

Perfect separation of responsibilities.

---

# Relationship with Earlier Concepts

```text
Entity
   |
   +--> Owns rules about itself

Aggregate
   |
   +--> Protects consistency
        within a boundary

Domain Service
   |
   +--> Coordinates rules
        across boundaries
```

Example:

```text
Account Aggregate
       +
Account Aggregate
       =
TransferService
```

---

# Easy Way to Remember

## Entity

**"Rules about me."**

Examples:

```text
Account
Order
Customer
```

---

## Aggregate

**"Objects that must stay consistent together."**

Example:

```text
Order
 + OrderLines
```

---

## Domain Service

**"Rules about us."**

Examples:

```text
Transfer money
Fraud check
Invoice settlement
Route calculation
```

---

# Quick Summary

| Concept        | Responsibility                   | Example              |
| -------------- | -------------------------------- | -------------------- |
| Entity         | Protects its own business rules  | `Account`, `Order`   |
| Aggregate      | Keeps related objects consistent | `Order + OrderLines` |
| Aggregate Root | Controls access to aggregate     | `Order`              |
| Domain Service | Coordinates multiple aggregates  | `TransferService`    |
| Value Object   | Represents a value               | `Money`, `Address`   |

---

# One-Line Summary

A **Domain Service** contains business operations that involve multiple aggregates and cannot naturally belong to any single entity, while the entities themselves continue to own and protect their own individual business rules.

# Understanding Repositories in a Natural Way

Before learning about Repositories, let's start with a simple question:

> If a Domain Service needs an Aggregate, where should it get it from?

Consider the transfer example from the previous chapter.

```java
transferService.transfer(
    accountAId,
    accountBId,
    Money.of(200)
);
```

To perform the transfer, the service needs:

- Account A
- Account B

Where do these accounts come from?

Should the Domain Service query the database directly?

Should it write SQL?

Should it know about JDBC, JPA, or PostgreSQL?

The answer is **No**.

That's exactly why we use a **Repository**.

---

# Imagine a Library

Suppose you're in a library.

You want a book.

Do you care:

```text
Which shelf?
Which rack?
Which storage room?
Which inventory database?
```

Not really.

You simply say:

```text
Give me the book with ID 123.
```

The library staff finds it and hands it to you.

Similarly, the domain says:

```java
accountRepository.findById(accountId);
```

The domain does not care how the account is stored.

The repository takes care of finding it.

---

# The Problem Without Repositories

Many developers start by allowing domain code to directly access the database.

Example:

```java
public Money totalRevenue(
        LocalDate day
) {

    EntityManager em = entityManager;

    Query query =
            em.createQuery(
                "select o from Order o where o.createdDate = :day"
            );

    // ...
}
```

At first this looks convenient.

Everything is right there.

But several problems appear.

---

# Problem 1: The Domain Learns the Database

Suppose your Order domain object contains:

```java
EntityManager
Query
ResultSet
Connection
```

Now your domain is tightly connected to persistence technology.

Your business logic can no longer run independently.

Instead of thinking:

```text
Order
Customer
Account
Money
```

your domain must now understand:

```text
SQL
JPA
Hibernate
EntityManager
```

The domain has learned too much.

## Why Is This Bad?

Suppose you want to unit test:

```java
order.submit();
```

If Order depends on:

```java
EntityManager
```

you may now need:

```text
Database
JPA
Configuration
Transactions
```

just to run a test.

Testing becomes harder.

The domain becomes harder to understand.

---

# Problem 2: Queries Get Scattered Everywhere

Imagine five services need Orders.

Each one writes its own query.

```java
Service A:
select * from order ...
```

```java
Service B:
select * from order ...
```

```java
Service C:
select * from order ...
```

Now suppose the storage changes.

Maybe:

```text
Column renamed
Table renamed
Join changed
```

You must update every place.

## Real-Life Analogy

Imagine every employee keeps their own copy of customer data.

```text
Employee A -> Spreadsheet
Employee B -> Spreadsheet
Employee C -> Spreadsheet
```

Now a customer's phone number changes.

You must update:

```text
Spreadsheet A
Spreadsheet B
Spreadsheet C
```

Messy.

Repositories centralize access.

---

# Problem 3: Storage Details Leak Into the Domain

The main problem is not simply that different developers write different SQL queries.

The real problem is this:

> Domain logic may receive an incomplete Aggregate and mistakenly treat it as complete.

Consider this Order Aggregate:

```text
Order Aggregate
|
+-- Order
+-- OrderLines
+-- ShippingAddress
```

The business rules of `Order` may depend on its lines.

For example:

- An Order cannot be submitted without at least one line.
- The Order total must equal the sum of its line subtotals.
- Every OrderLine must have a quantity greater than zero.

For these rules to work correctly, the `Order` must have all the data required by the Aggregate.

---

## The Core Trap: Partially Loaded Objects

In the database, an Order and its lines are often stored in separate tables:

```text
orders
order_lines
```

Loading the complete Aggregate may require a join or multiple queries.

To improve performance, developers may create different ways to load an Order.

### Query A: Load Only the Order Header

```sql
SELECT *
FROM orders
WHERE id = 123;
```

This query loads only the main Order record.

In memory, the result may look like this:

```text
Order #123
Status: DRAFT
Lines: Not loaded
```

Depending on the ORM configuration, `lines` may appear as:

- An empty list
- An uninitialized lazy-loading proxy
- A collection that fails when accessed outside the persistence session

### Query B: Load the Complete Aggregate

```sql
SELECT o.*, l.*
FROM orders o
LEFT JOIN order_lines l
    ON l.order_id = o.id
WHERE o.id = 123;
```

This query loads the Order and its OrderLines.

In memory, the result looks like this:

```text
Order #123
Status: DRAFT
Lines:
  - Laptop x 1
  - Mouse x 2
```

The second object is complete enough for the Order's business rules to run safely.

---

## How Storage Details Leak Into Business Logic

Suppose a repository exposes a method that loads only the Order header:

```java
Order order =
        orderRepository.findHeaderOnly(orderId);
```

The developer may have created this method to make a UI screen load faster.

Later, another part of the application receives the same `Order` object and runs business logic:

```java
order.submit();
```

The `submit()` method protects an important business rule:

```java
public void submit() {
    if (lines.isEmpty()) {
        throw new IllegalStateException(
            "Cannot submit an empty order"
        );
    }

    status = OrderStatus.SUBMITTED;
}
```

The rule itself is correct:

> An Order with no items cannot be submitted.

But the object was loaded without its lines.

Therefore, this check may return `true`:

```java
lines.isEmpty()
```

The method throws an exception even though the database actually contains OrderLines.

### What Exists in the Database

```text
Order #123
|
+-- Laptop x 1
+-- Mouse x 2
```

### What the Domain Object Sees in Memory

```text
Order #123
|
+-- No lines loaded
```

The Order is rejected not because it is truly empty, but because the query did not load the complete Aggregate.

The business rule has now become dependent on a storage decision.

That is what it means for the **storage shape to leak into the domain**.

---

## The Domain Cannot Tell What It Received

When the domain sees this:

```java
lines.isEmpty()
```

it cannot reliably distinguish between two very different situations.

### Situation 1: The Order Is Truly Empty

```text
Database:

Order #123
No OrderLines exist
```

In this situation, preventing submission is correct.

### Situation 2: The Lines Were Not Loaded

```text
Database:

Order #123
+-- Laptop x 1
+-- Mouse x 2

Java memory:

Order #123
No OrderLines loaded
```

In this situation, preventing submission is wrong.

Both situations may look identical to the domain:

```java
lines.isEmpty() == true
```

The `Order` object has no safe way to know whether:

- It genuinely contains no lines, or
- Its lines exist in the database but were not fetched.

The domain is forced to trust that whoever loaded the object loaded it correctly.

---

## The More Dangerous Result: Data Corruption

A false validation error is bad, but a partially loaded Aggregate can cause an even more serious problem.

Suppose the Order calculates its total from its lines:

```java
public Money total() {
    return lines.stream()
            .map(OrderLine::subtotal)
            .reduce(Money.zero(), Money::add);
}
```

The database contains:

```text
Laptop = $1000
Mouse  = $50

Actual Total = $1050
```

But because the OrderLines were not loaded, Java sees:

```text
lines = []
```

The calculation returns:

```text
Total = $0
```

If that partially loaded Order is saved, the system could overwrite the correct total with zero.

```text
Correct database value: $1050
Incorrect saved value:  $0
```

The data was not corrupted by a wrong business formula.

It was corrupted because the formula ran on an incomplete Aggregate.

---

## Why This Makes the Domain Unreliable

Business logic should work with domain concepts such as:

```text
Order
OrderLine
Money
Customer
```

It should not need to ask questions such as:

```text
Were the lines loaded eagerly?
Is this collection a lazy proxy?
Is the persistence session still open?
Did the query include the required JOIN?
```

Once domain behavior depends on these questions, database loading choices have crossed into the business model.

The domain is no longer persistence-ignorant.

---

## How the Aggregate Pattern Fixes This

DDD solves this problem by separating **business operations** from **read-only display queries**.

### Rule 1: Load the Complete Aggregate for Business Logic

When a Repository returns an Aggregate for modification or rule execution, it must return the complete consistency boundary required by those rules.

```java
Order order =
        orderRepository.findById(orderId)
                .orElseThrow(OrderNotFoundException::new);

order.submit();

orderRepository.save(order);
```

The Repository must guarantee that `Order` contains its required internal objects:

```text
Order
+-- OrderLines
+-- ShippingAddress
```

Now `order.submit()` can safely trust the object in memory.

### Rule 2: Use a Read Model for Display-Only Screens

Sometimes the UI only needs:

```text
Order ID
Order date
Customer name
Total amount
```

Loading the full Aggregate would be unnecessary.

However, the solution is not to return a half-loaded `Order`.

Instead, return a dedicated DTO or read model:

```java
public record OrderSummaryDto(
        OrderId orderId,
        String customerName,
        LocalDate orderDate,
        BigDecimal total
) {
}
```

A read query can load exactly the fields needed by the screen:

```sql
SELECT
    o.id,
    c.name AS customer_name,
    o.created_date,
    o.total
FROM orders o
JOIN customers c
    ON c.id = o.customer_id;
```

The result is used only for display:

```java
List<OrderSummaryDto> summaries =
        orderQueryService.findOrderSummaries();
```

Because a DTO has no domain behavior such as `submit()`, nobody can accidentally run Order invariants on incomplete data.

---

## Business Model and Read Model Have Different Jobs

| Purpose                                             | What to Load                                                         | How to Load                              |
| --------------------------------------------------- | -------------------------------------------------------------------- | ---------------------------------------- |
| Execute business logic, such as `order.submit()`    | Complete `Order` Aggregate with its required lines and Value Objects | Load through the Repository              |
| Display a dashboard, report, search result, or list | Lightweight DTO containing only the required fields                  | Use a projection or dedicated read query |

The important separation is:

```text
Repository
    -> Complete Aggregate
    -> Safe for business behavior
```

```text
Read Query
    -> Lightweight DTO
    -> Safe for display only
```

Avoid this:

```text
Repository
    -> Partially loaded Aggregate
    -> Unsafe for business behavior
```

---

## Complete Example

### Executing Business Logic

```java
@Transactional
public void submitOrder(OrderId orderId) {
    Order order = orderRepository.findById(orderId)
            .orElseThrow(OrderNotFoundException::new);

    order.submit();

    orderRepository.save(order);
}
```

The Repository returns the complete Aggregate, so the business rule can safely inspect its lines.

### Displaying an Order List

```java
public List<OrderSummaryDto> listOrders() {
    return orderQueryService.findOrderSummaries();
}
```

The query returns only the fields required by the screen. It does not create incomplete `Order` objects.

---

## Easy Rule to Remember

When executing behavior:

```java
order.submit();
order.cancel();
order.addLine(...);
order.removeLine(...);
```

use:

```text
Complete Aggregate from the Repository
```

When displaying information:

```text
Dashboard
Report
Search screen
Order history list
```

use:

```text
DTO or Read Model from a dedicated query
```

---

## Key Takeaway

The Repository's job is not only to retrieve database records.

It must also guarantee:

> If the Repository returns an Aggregate, that Aggregate is complete enough for its business rules to run safely.

When storage shape leaks, business rules start depending on SQL joins, ORM fetch settings, and lazy-loading behavior.

By loading complete Aggregates for business operations and using lightweight DTOs for display-only queries, the domain never has to operate on incomplete or half-loaded data.

---

# Enter Repository

A Repository is:

> The domain's collection of aggregates.

Think of it as the Aggregate's storage gateway.

---

# Example

```java
public interface OrderRepository {

    Optional<Order> findById(
            OrderId id
    );

    List<Order> findByCustomer(
            CustomerId customerId,
            LocalDate date
    );

    void save(
            Order order
    );
}
```

Notice something important.

There is no:

```java
SQL
Table
Column
EntityManager
Connection
```

The repository speaks the language of the domain.

---

# The Domain View

The domain sees:

```java
OrderRepository
```

and thinks:

```text
Give me an Order.
Save an Order.
Find Orders.
```

That's all.

The domain never asks:

```text
Which table?
Which database?
Which query?
```

---

# Real-Life Analogy

Imagine ordering food through an app.

You say:

```text
I want a pizza.
```

You do NOT say:

```text
Call restaurant.
Talk to chef.
Turn oven on.
Bake for 12 minutes.
Pack in box.
```

The app handles all that.

Similarly:

```java
repository.findById(id);
```

The repository hides all storage complexity.

---

# Who Implements the Repository?

The repository interface belongs to the domain.

Example:

```java
public interface OrderRepository {
}
```

But someone still must talk to the database.

That's the job of the infrastructure layer.

Example:

```java
@Repository
public class JpaOrderRepository
        implements OrderRepository {
}
```

---

# Example Implementation

```java
@Repository
public class JpaOrderRepository
        implements OrderRepository {

    private final JpaRepository<OrderJpa, Long> jpa;

    @Override
    public Optional<Order> findById(
            OrderId id
    ) {

        return jpa.findById(
                        id.value()
                )
                .map(OrderJpa::toDomain);
    }

    @Override
    public void save(
            Order order
    ) {

        jpa.save(
            OrderJpa.from(order)
        );
    }
}
```

Notice the separation.

## Domain Layer

Knows:

```java
Order
OrderRepository
OrderId
```

Does NOT know:

```java
JpaOrderRepository
Hibernate
SQL
```

## Infrastructure Layer

Knows:

```java
SQL
Hibernate
JPA
Database
```

and

```java
OrderRepository
```

because it implements it.

---

# Dependency Direction

Many developers think:

```text
Domain
   |
   v
Database
```

But DDD wants:

```text
Domain
   |
   v
Repository Interface

Infrastructure
   |
   v
Repository Implementation
   |
   v
Database
```

Visualized:

```text
Domain
--------------------------------

Order
OrderRepository

           ▲
           |
           |
Infrastructure
--------------------------------

JpaOrderRepository

           |
           v

Database
```

The domain depends only on the interface.

The infrastructure depends on the domain.

This is called:

```text
Dependency Inversion
```

---

# How Spring Wires Everything

Suppose we have:

```java
public interface OrderRepository {
}
```

and

```java
@Repository
public class JpaOrderRepository
        implements OrderRepository {
}
```

Now:

```java
@Service
public class OrderService {

    private final OrderRepository repository;

}
```

Spring automatically injects:

```java
JpaOrderRepository
```

behind:

```java
OrderRepository
```

The service never knows the concrete implementation.

---

# What a Repository Really Is

Many developers think:

> Repository = Data Access Class

Not exactly.

In DDD, a Repository is:

> A conceptual collection of Aggregates.

Think of it like:

```text
AccountRepository
```

means:

```text
A collection of Accounts
```

Similar to:

```java
List<Account>
```

but backed by storage.

```java
repository.findById(id);
```

feels like:

```java
accounts.get(id);
```

---

# What Should Be Inside a Repository?

Good repository methods:

```java
findById()
save()
findByCustomer()
findByCustomerAndDate()
```

These make sense in domain language.

---

# What Should NOT Be Inside?

Bad examples:

```java
executeQuery()
```

```java
runSql()
```

```java
createResultSet()
```

```java
openConnection()
```

These expose storage concerns.

The domain should never see them.

---

# Property 1: Repository Returns Whole Aggregates

Suppose:

```text
Order Aggregate
    |
    +-- OrderLines
    +-- ShippingAddress
```

Repository should return:

```java
Order
```

with everything required by the Aggregate.

Example:

```java
Order order =
        repository.findById(id);
```

The order should be ready for business rules.

## Bad

```java
repository.findOrderLineById(...)
```

Why?

Because:

```text
OrderLine
```

is not an Aggregate Root.

It belongs inside:

```text
Order Aggregate
```

Remember:

> Repositories work with Aggregate Roots.

Not internal objects.

---

# Property 2: Repository Does Not Contain Business Rules

Repository responsibility:

```text
Load data
Save data
Map data
```

Only that.

Bad:

```java
if(orderTotal > 10000) {
    throw ...
}
```

inside repository.

Business rules belong in:

```java
Order
```

or

```java
OrderService
```

or

```java
DomainService
```

depending on the rule.

Repository should simply do:

```text
Database
    <-->
Repository
    <-->
Domain
```

Translation only.

---

# Complete Flow

Imagine an Order submission.

### Step 1

Load aggregate.

```java
Order order =
    repository.findById(orderId);
```

### Step 2

Run business logic.

```java
order.submit();
```

Order validates:

```text
Must contain lines.
Must be draft.
```

### Step 3

Save aggregate.

```java
repository.save(order);
```

Notice:

### Repository

Responsible for:

```text
Loading
Saving
Mapping
```

### Order

Responsible for:

```text
Business Rules
Validation
Consistency
```

Clear separation.

---

# Relationship With Previous Concepts

```text
Value Object
      |
      v
Entity
      |
      v
Aggregate
      |
      v
Domain Service
      |
      v
Repository
```

Example:

```text
TransferService
        |
        v
AccountRepository
        |
        v
Account Aggregate
```

The service asks the repository for accounts.

The repository loads them.

The accounts enforce their rules.

Everyone has exactly one responsibility.

---

# Easy Way to Remember

## Entity

**"I protect my own rules."**

Example:

```text
Account
Order
Customer
```

## Aggregate

**"I keep related objects consistent."**

Example:

```text
Order
 + OrderLines
```

## Domain Service

**"I coordinate multiple aggregates."**

Example:

```text
TransferService
```

## Repository

**"I fetch and store aggregates."**

Example:

```text
AccountRepository
OrderRepository
CustomerRepository
```

---

# Quick Summary

| Concept                   | Responsibility                 | Example              |
| ------------------------- | ------------------------------ | -------------------- |
| Entity                    | Own business rules             | `Order`, `Account`   |
| Aggregate                 | Maintain consistency boundary  | `Order + OrderLines` |
| Aggregate Root            | Entry point into aggregate     | `Order`              |
| Domain Service            | Coordinate multiple aggregates | `TransferService`    |
| Repository                | Load and save aggregates       | `OrderRepository`    |
| Infrastructure Repository | Database implementation        | `JpaOrderRepository` |

---

# One-Line Summary

A **Repository** is the domain's collection of aggregates. It hides all database details, returns complete aggregates, saves them back to storage, and allows the domain model to remain completely unaware of how data is actually stored.

# Understanding Business Rules in a Natural Way

Before learning about Business Rules, let's start with a simple question:

> Where should a business rule live so nobody can forget it or bypass it?

Consider a simple rule:

```text
An order cannot ship before it is confirmed.
```

Sounds simple.

Yet many systems implement this rule incorrectly.

---

# The Main Problem

Suppose the business says:

```text
An order cannot ship before it is confirmed.
```

Many developers implement it in multiple places.

### Shipping Service

```java
if(order.getStatus() == CONFIRMED) {
    ship(order);
}
```

### Batch Job

```java
if(order.getStatus() == CONFIRMED) {
    ship(order);
}
```

### API Layer

```java
if(order.getStatus() == CONFIRMED) {
    ship(order);
}
```

Everything works until someone forgets.

---

## What Goes Wrong?

A new developer writes:

```java
public void processOrder(Order order) {
    order.setStatus(OrderStatus.SHIPPED);
}
```

and forgets the check.

Now:

```text
API -> Safe
Batch Job -> Safe
New Process -> Unsafe
```

The rule exists only where people remembered it.

---

# Why This Is Dangerous

Suppose the rule changes.

Old rule:

```text
Order can ship only if CONFIRMED
```

New rule:

```text
Order can ship if:
- CONFIRMED
- PREPAID
```

Now you must find every place containing:

```java
status == CONFIRMED
```

Miss one location and the system behaves differently depending on where the order was shipped from.

---

# The Real Problem

The business has a concept:

```text
Shippable
```

But the code does not.

Developers repeatedly write:

```java
status == CONFIRMED
```

instead of:

```java
order.canShip()
```

The business rule is duplicated rather than modeled.

---

# Better Design

Put the rule inside the Order.

```java
public class Order {

    private OrderStatus status;

    public boolean canShip() {
        return status == OrderStatus.CONFIRMED;
    }
}
```

Now the business concept exists directly in code.

---

# Even Better: Enforce the Rule

Don't just expose the rule.

Protect it.

```java
public class Order {

    private OrderStatus status;

    public boolean canShip() {
        return status == OrderStatus.CONFIRMED;
    }

    public void ship() {

        if (!canShip()) {
            throw new IllegalStateException(
                "Cannot ship an unconfirmed order"
            );
        }

        status = OrderStatus.SHIPPED;
    }
}
```

Now nobody can bypass the rule.

The caller simply does:

```java
order.ship();
```

The Order decides whether shipping is allowed.

---

# Why This Is Better

Suppose 100 different places can ship orders.

```text
API
Batch Job
Import Job
Mobile App
Admin Tool
```

All of them call:

```java
order.ship();
```

The rule exists once.

When the rule changes, one location changes.

---

# Three Types of Business Rules

Not all business rules are the same.

DDD separates them into three categories.

---

# 1. Invariant

An invariant is a rule that must always remain true.

## Example

```text
Account balance can never be negative.
```

Valid:

```text
100
50
0
```

Invalid:

```text
-10
```

### Implementation

```java
public void withdraw(Money amount) {

    Money next = balance.minus(amount);

    if (next.isNegative()) {
        throw new InsufficientFundsException();
    }

    balance = next;
}
```

The object protects itself.

Nobody can accidentally create a negative balance.

### Easy Memory Trick

```text
Invariant = Must always be true.
```

Examples:

```text
Balance >= 0
Quantity > 0
Email not empty
```

---

# 2. Constraint

A constraint protects a state transition.

It answers:

```text
Can I move from State A to State B?
```

### Example

```text
DRAFT
  |
  v
CONFIRMED
  |
  v
SHIPPED
```

Rule:

```text
Cannot ship before confirmation.
```

### Implementation

```java
public void ship() {

    if(status != CONFIRMED) {
        throw new IllegalStateException();
    }

    status = SHIPPED;
}
```

### Easy Memory Trick

```text
Constraint = Guard a transition.
```

Examples:

```text
Cannot ship before confirmation.
Cannot approve twice.
Cannot close an unopened ticket.
```

---

# 3. Derivation

A derivation is a value calculated from other facts.

It is not a restriction.

### Example

```text
Laptop  = 1000
Mouse   = 50
Monitor = 500
```

Total:

```text
1550
```

Instead of storing the total manually:

```java
private Money total;
```

calculate it.

```java
public Money total() {

    return lines.stream()
            .map(OrderLine::subtotal)
            .reduce(
                Money.zero(),
                Money::add
            );
}
```

### Easy Memory Trick

```text
Derivation = Calculate from facts.
```

Examples:

```text
Order Total
Invoice Total
Average Rating
```

---

# Comparison Table

| Rule Type  | Meaning             | Example                         |
| ---------- | ------------------- | ------------------------------- |
| Invariant  | Always true         | Balance can never be negative   |
| Constraint | Controls transition | Cannot ship before confirmation |
| Derivation | Calculated value    | Order total = sum of lines      |

---

# Why Aggregates Matter

Suppose we have:

```text
Order Aggregate
|
+-- OrderLines
+-- Discount
```

Business rule:

```text
Discount cannot make the total negative.
```

To validate this rule, the Order needs:

```text
OrderLines
Discount
```

Therefore all data needed for the rule should live inside the same Aggregate.

### Example

```java
public void applyDiscount(Money discount) {

    if(total().minus(discount)
            .isNegative()) {

        throw new IllegalArgumentException(
            "Discount too large"
        );
    }

    this.discount = discount;
}
```

The rule and the data needed by the rule stay together.

---

# When Does a Rule Belong in a Domain Service?

Ask one question:

> Can one object enforce this rule by itself?

If yes:

```text
Put the rule on the Aggregate.
```

Examples:

```java
order.ship();
order.cancel();
account.withdraw();
account.deposit();
```

---

If the rule involves multiple Aggregates:

```text
Account A
+
Account B
```

then it belongs in a Domain Service.

Example:

```java
transferService.transfer(
    from,
    to,
    amount
);
```

because no single Account owns the transfer.

---

# Easy Rule To Remember

## Invariant

```text
Must always be true.
```

Example:

```text
Balance >= 0
```

---

## Constraint

```text
Can this state change happen?
```

Example:

```text
Cannot ship before confirmation.
```

---

## Derivation

```text
Calculate from existing facts.
```

Example:

```text
Order Total
```

---

## Aggregate Rule

```text
Uses data inside one Aggregate.
```

Examples:

```java
order.ship();
order.applyDiscount();
```

---

## Domain Service Rule

```text
Uses multiple Aggregates.
```

Examples:

```java
transferMoney();
fraudCheck();
settleInvoices();
```

---

# Quick Summary

| Concept             | Responsibility                 | Example                         |
| ------------------- | ------------------------------ | ------------------------------- |
| Invariant           | Must always remain true        | Balance >= 0                    |
| Constraint          | Controls state transitions     | Cannot ship before confirmation |
| Derivation          | Calculates values              | Order total                     |
| Aggregate Rule      | Uses data inside one aggregate | order.ship()                    |
| Domain Service Rule | Uses multiple aggregates       | transferService.transfer()      |

---

# One-Line Summary

A well-modeled business rule lives exactly once, inside the object or aggregate that owns it, so callers cannot forget it, duplicate it, or bypass it. Rules involving a single aggregate stay inside that aggregate, while rules involving multiple aggregates belong in a Domain Service.

# Understanding Domain Events in a Natural Way

Before learning about Domain Events, let's start with a simple question:

> What should happen when something important occurs in the system?

For example:

```text
An Order is submitted.
An Invoice is paid.
A Customer is suspended.
```

Many parts of the system may care about these facts.

When an Order is submitted:

```text
Inventory wants to reserve stock.
Email service wants to send a confirmation.
Audit service wants to record the action.
Loyalty service wants to award points.
```

Should the Order know about all of them?

DDD says:

**No.**

That's why we use **Domain Events**.

---

# What Is a Domain Event?

A Domain Event is:

> A record that something already happened in the domain.

Examples:

```text
OrderSubmitted
InvoicePaid
CustomerSuspended
PaymentReceived
```

Notice the naming.

All are:

```text
Past tense
```

because they represent facts, not requests.

---

# Real-Life Analogy

Imagine an airport announcement.

```text
Flight AI501 has landed.
```

The announcement does not directly call:

```text
Baggage Team
Cleaning Team
Ground Staff
Security Team
```

Instead:

```text
Announcement made
        ↓
Whoever cares reacts
```

A Domain Event works exactly the same way.

---

# The Problem Without Domain Events

Suppose we write Order submission like this:

```java
public void submit() {

    if(lines.isEmpty()) {
        throw new IllegalStateException(
            "Empty Order"
        );
    }

    status = SUBMITTED;

    inventory.reserve(items);
    mailer.sendConfirmation(orderId);
    auditor.record(orderId);
}
```

Looks reasonable.

But this creates problems.

---

# Problem 1: The Order Knows Too Much

The Order should mainly care about:

```text
Order Status
Order Lines
Customer
Total
```

But now it also knows:

```text
Inventory System
Mailer
Auditor
```

Tomorrow someone adds:

```text
Tax Engine
Loyalty System
Fulfillment Center
Recommendation Engine
```

Now Order becomes:

```text
A giant coordinator
```

instead of:

```text
A business object
```

---

# Problem 2: Every New Requirement Changes Order

Initially:

```java
inventory.reserve(...);
mailer.sendConfirmation(...);
```

Later:

```java
inventory.reserve(...);
mailer.sendConfirmation(...);
auditor.record(...);
loyalty.awardPoints(...);
taxEngine.calculate(...);
```

Every new subscriber forces a change inside Order.

This violates:

```text
Closed for modification
Open for extension
```

---

# Problem 3: Slow Dependencies Slow Everything

Suppose Email Service is slow.

```java
mailer.sendConfirmation(orderId);
```

Takes:

```text
5 seconds
```

Now submitting an order also takes:

```text
5 seconds
```

Even though the Order itself finished instantly.

The Order is blocked waiting for another system.

---

# The Real Problem

The business rule is:

```text
Record that the Order was submitted.
```

But the code became:

```text
Reserve inventory
Send email
Write audit
Award points
Calculate tax
```

The Order is doing too many unrelated jobs.

---

# Enter Domain Events

Instead of calling other systems directly:

```java
inventory.reserve(...);
mailer.sendConfirmation(...);
auditor.record(...);
```

The Order simply records a fact.

```java
OrderSubmitted
```

That's it.

---

# Example Event

```java
public record OrderSubmitted(
        OrderId orderId,
        CustomerId customerId,
        Money total
) {
}
```

This event says:

```text
Order 123 was submitted.
Customer ABC submitted it.
Total was $500.
```

Nothing more.

It doesn't perform any action.

It only records a fact.

---

# The Order Raises the Event

```java
public class Order {

    private final List<DomainEvent>
            domainEvents = new ArrayList<>();

    public void submit() {

        if(lines.isEmpty()) {
            throw new IllegalStateException(
                "Empty Order"
            );
        }

        status = SUBMITTED;

        domainEvents.add(
            new OrderSubmitted(
                id,
                customerId,
                total()
            )
        );
    }
}
```

Notice what is missing.

```java
inventory.reserve(...);
mailer.sendConfirmation(...);
auditor.record(...);
```

The Order doesn't know they exist.

---

# What Happens After the Event?

Different handlers listen.

## Inventory Handler

```java
public class InventoryReservationHandler {

    public void on(
            OrderSubmitted event
    ) {

        reserveInventory(
            event.orderId()
        );
    }
}
```

---

## Email Handler

```java
public class EmailHandler {

    public void on(
            OrderSubmitted event
    ) {

        sendConfirmation(
            event.customerId()
        );
    }
}
```

---

## Audit Handler

```java
public class AuditHandler {

    public void on(
            OrderSubmitted event
    ) {

        recordAudit(
            event.orderId()
        );
    }
}
```

```java
/*The Application Service (The Glue)
This service manages the transaction boundary. It calls the domain logic, saves the state, and dispatches the accumulated events:*/
public class OrderApplicationService {
    private final OrderRepository orderRepository;
    private final EventPublisher eventPublisher;

    public void submitOrder(OrderId orderId) {
        // 1. Load the aggregate root
        Order order = orderRepository.findById(orderId);

        // 2. Execute business logic (appends event inside Order)
        order.submit();

        // 3. Persist aggregate state
        orderRepository.save(order);

        // 4. Extract generated events and dispatch them
        for (DomainEvent event : order.unpublishedEvents()) {
            eventPublisher.publish(event);
        }

        // 5. Clear events after publishing so they aren't re-sent later
        order.clearEvents(); 
    }
}
```

```java
 /*The Event Publisher / Bus
The EventPublisher directs the OrderSubmitted event to any registered listeners:*/
public class SimpleEventBus implements EventPublisher {
    private final InventoryReservationHandler inventoryHandler;

    @Override
    public void publish(DomainEvent event) {
        if (event instanceof OrderSubmitted orderSubmitted) {
            // Invokes the handler when an OrderSubmitted event is published
            inventoryHandler.on(orderSubmitted);
        }
    }
}
```

Now the flow becomes:

```text
Order Submitted
        ↓
 OrderSubmitted Event
        ↓
 ┌─────────────┐
 │ Inventory   │
 ├─────────────┤
 │ Email       │
 ├─────────────┤
 │ Audit       │
 └─────────────┘
```

---

# The Biggest Benefit: Decoupling

Before:

```text
Order
  |
  +--> Inventory
  +--> Email
  +--> Audit
```

Order depends on everybody.

---

After:

```text
Order
  |
  +--> OrderSubmitted Event

Inventory listens
Email listens
Audit listens
```

Order depends on nobody.

---

# Adding New Features Becomes Easy

Suppose tomorrow we add:

```text
Loyalty Points Service
```

Before:

```java
order.submit()
```

must change.

---

With events:

```java
public class LoyaltyHandler {

    public void on(
            OrderSubmitted event
    ) {
        awardPoints(...);
    }
}
```

The Order class never changes.

That's the power of Domain Events.

---

# Domain Event vs Command

This confuses many developers.

## Command

A command is:

```text
Please do something.
```

Examples:

```text
SubmitOrder
PayInvoice
SendEmail
```

A command talks about the future.

---

## Event

An event is:

```text
Something already happened.
```

Examples:

```text
OrderSubmitted
InvoicePaid
EmailSent
```

An event talks about the past.

---

# Easy Memory Trick

```text
Command → Future
Event   → Past
```

Examples:

```text
SubmitOrder     -> Command
OrderSubmitted  -> Event

PayInvoice      -> Command
InvoicePaid     -> Event
```

---

# What Information Should an Event Carry?

Events should carry only the data consumers need.

Good:

```java
public record OrderSubmitted(
        OrderId orderId,
        CustomerId customerId,
        Money total
) {
}
```

Contains:

```text
Order ID
Customer ID
Snapshot Total
```

---

# What Should NOT Be Inside?

Bad:

```java
public record OrderSubmitted(
        Order order
) {
}
```

Why?

Because Order is mutable.

The Order may change later.

The event now stops representing:

```text
What happened.
```

and becomes:

```text
Current state of Order.
```

which is wrong.

---

# Events Are Snapshots

Imagine:

```text
10:00 AM
Order Submitted
Total = $500
```

Event created:

```text
OrderSubmitted
Total = $500
```

Later:

```text
11:00 AM
Order Modified
Total = $700
```

The event should still say:

```text
Total = $500
```

because that's what was true when the event happened.

---

# The Two Golden Rules

## Rule 1

The Aggregate records the event.

It does NOT call the consequence.

Good:

```java
domainEvents.add(
    new OrderSubmitted(...)
);
```

Bad:

```java
inventory.reserve(...);
```

inside Order.

---

## Rule 2

Events are facts.

Use past tense.

Good:

```text
OrderSubmitted
InvoicePaid
CustomerSuspended
```

Bad:

```text
SubmitOrder
PayInvoice
SuspendCustomer
```

Those are commands.

---

# Relationship with Previous DDD Concepts

```text
Entity
    ↓
Aggregate
    ↓
Business Rules
    ↓
Domain Event
    ↓
Handlers react
```

Example:

```text
Order Aggregate
        ↓
OrderSubmitted Event
        ↓
Inventory Handler
Email Handler
Audit Handler
```

Each aggregate stays focused on its own rules.

---

# Complete Example Flow

```text
Customer clicks Submit
        ↓
Order.submit()
        ↓
Order status = SUBMITTED
        ↓
OrderSubmitted Event Created
        ↓
Event Published
        ↓
Inventory reserves stock
Email sends confirmation
Audit records activity
Loyalty awards points
```

Notice:

```text
Order does not know
about Inventory,
Email,
Audit,
or Loyalty.
```

It only records a fact.

---

# Quick Summary

| Concept       | Meaning                        | Example                    |
| ------------- | ------------------------------ | -------------------------- |
| Command       | Request something to happen    | SubmitOrder                |
| Event         | Record that something happened | OrderSubmitted             |
| Aggregate     | Raises the event               | Order                      |
| Event Handler | Reacts to the event            | InventoryHandler           |
| Event Data    | Snapshot of facts              | OrderId, CustomerId, Total |

---

# One-Line Summary

A Domain Event is an immutable record of something that already happened in the domain. The Aggregate records the fact and stops, while any number of handlers can react independently, keeping the domain decoupled, scalable, and easier to evolve.

# Understanding Anemic vs Rich Domain Model in a Natural Way

Before learning about Anemic and Rich Domain Models, let's start with a simple question:

> Where should business rules live?
>
> Inside the object that owns the data?
>
> Or inside separate services?

The answer to this question determines whether you have an **Anemic Domain Model** or a **Rich Domain Model**.

---

# A Real Banking Example

Imagine a banking system.

We have an Account:

```text
Account
-------
Balance = $1000
Status  = ACTIVE
```

Business rules:

```text
A suspended account cannot transfer money.
A suspended account cannot withdraw money.
The balance can never go negative.
```

The question is:

> Where should these rules live?

---

# What Is an Anemic Domain Model?

An Anemic Domain Model is an object that contains:

```text
Fields
Getters
Setters
```

but almost no business behavior.

Example:

```java
public class Account {

    private Money balance;
    private boolean suspended;

    public Money getBalance() {
        return balance;
    }

    public void setBalance(Money balance) {
        this.balance = balance;
    }

    public boolean isSuspended() {
        return suspended;
    }

    public void setSuspended(boolean suspended) {
        this.suspended = suspended;
    }
}
```

This object is basically a data container.

---

# Where Are the Rules?

All the rules move into services.

```java
public class TransferService {

    public void transfer(
            Account from,
            Account to,
            Money amount
    ) {

        if(from.isSuspended()
                || to.isSuspended()) {
            throw new AccountSuspendedException();
        }

        if(from.getBalance()
                .compareTo(amount) < 0) {
            throw new InsufficientFundsException();
        }

        from.setBalance(
                from.getBalance()
                    .minus(amount)
        );

        to.setBalance(
                to.getBalance()
                    .plus(amount)
        );
    }
}
```

The service contains all the intelligence.

The Account contains none.

---

# Why This Looks Good Initially

Many teams like this because:

```text
Entities look simple.
Services contain logic.
Everything compiles.
Tests pass.
```

The problem appears later.

---

# Problem 1: Rules Get Duplicated

Suppose another developer writes:

```java
public class WithdrawalService {

    public void withdraw(
            Account account,
            Money amount
    ) {

        if(account.isSuspended()) {
            throw new AccountSuspendedException();
        }

        account.setBalance(
                account.getBalance()
                        .minus(amount)
        );
    }
}
```

Notice something.

The same rule appears again:

```text
A suspended account cannot operate.
```

Now the rule exists in:

```text
TransferService
WithdrawalService
PaymentService
RefundService
```

Soon the rule is duplicated everywhere.

---

# Problem 2: Anybody Can Break the Rules

Suppose a new developer writes:

```java
account.setBalance(
        Money.of(-100)
);
```

No validation.

No guard.

No exception.

The Account silently becomes:

```text
Balance = -100
```

which is illegal.

Why?

Because the object has no control over its own state.

---

# Problem 3: Entity Becomes a DTO

Compare these two classes.

### Account Entity

```java
class Account {
    private Money balance;
    private boolean suspended;
}
```

### API Response

```java
class AccountResponse {
    private Money balance;
    private boolean suspended;
}
```

What's the difference?

Almost none.

The domain object and transport object start looking identical.

The domain model loses its meaning.

---

# Enter Rich Domain Model

A Rich Domain Model puts behavior where the data lives.

The object that owns the balance manages the balance.

---

# Account Protects Itself

```java
public class Account {

    private Money balance;
    private boolean suspended;

    public void debit(Money amount) {

        requireActive();

        if(balance.compareTo(amount) < 0) {
            throw new InsufficientFundsException();
        }

        balance = balance.minus(amount);
    }

    public void credit(Money amount) {

        requireActive();

        balance = balance.plus(amount);
    }

    private void requireActive() {

        if(suspended) {
            throw new AccountSuspendedException();
        }
    }
}
```

Now the rules live with the data.

---

# What Changed?

Before:

```java
from.getBalance()
from.setBalance(...)
```

After:

```java
from.debit(amount)
```

The Account itself decides:

```text
Am I suspended?
Do I have enough money?
Can this operation happen?
```

---

# The Service Becomes Smaller

A transfer is still a cross-aggregate operation.

So we still need a Domain Service.

But now the service coordinates.

It doesn't own account rules.

```java
public class TransferService {

    public void transfer(
            Account from,
            Account to,
            Money amount
    ) {

        from.debit(amount);
        to.credit(amount);
    }
}
```

The service coordinates.

The Account enforces.

Perfect separation.

---

# Real-Life Analogy

Imagine a bank cashier.

### Anemic Model

The cashier performs every validation.

```text
Check balance
Check suspension
Check limits
Update balance
```

The account itself knows nothing.

---

### Rich Model

The cashier simply requests:

```text
Debit $100
```

The account responds:

```text
Allowed
```

or

```text
Rejected: Insufficient funds
```

The account protects itself.

---

# The Test for an Anemic Model

Ask:

> Can someone change the object's important state without the object noticing?

Example:

```java
account.setBalance(Money.of(-500));
```

If that works:

```text
Anemic Model
```

because the object cannot enforce its own rules.

---

# The Test for a Rich Model

Ask:

> Is every state change forced through a business operation?

Example:

```java
account.debit(amount);
account.credit(amount);
account.freeze();
account.unfreeze();
```

Every state change passes through business logic.

That is a Rich Domain Model.

---

# Naming Tells the Story

Anemic models speak in storage language.

```java
getBalance()
setBalance()
getStatus()
setStatus()
```

These names describe data.

---

Rich models speak in business language.

```java
debit()
credit()
withdraw()
deposit()
freeze()
submit()
ship()
```

These names describe actions the business understands.

---

# Strong E-Commerce Example

Imagine an Order.

Business rule:

```text
Cannot ship an unconfirmed order.
```

### Anemic Version

```java
public class Order {
    private OrderStatus status;
}
```

Every caller remembers the rule:

```java
if(order.getStatus() == CONFIRMED) {
    ship(order);
}
```

Soon this check appears everywhere.

---

### Rich Version

```java
public class Order {

    private OrderStatus status;

    public void ship() {

        if(status != CONFIRMED) {
            throw new IllegalStateException(
                "Order is not confirmed"
            );
        }

        status = SHIPPED;
    }
}
```

Caller simply says:

```java
order.ship();
```

The Order guarantees the rule.

---

# Rich Model Does NOT Mean No Services

This is a common misunderstanding.

Rich Domain Models still have services.

Example:

```text
Transfer money between two accounts.
```

This requires:

```text
Account A
Account B
```

So a Domain Service is still needed.

```java
transferService.transfer(
        from,
        to,
        amount
);
```

But the service should call:

```java
from.debit(amount);
to.credit(amount);
```

Not:

```java
from.setBalance(...);
to.setBalance(...);
```

That's the difference.

---

# When Anemic Is Actually Fine

Not everything needs behavior.

DTOs are supposed to be bags of data.

Example:

```java
public record AccountResponse(
        String accountNumber,
        BigDecimal balance,
        boolean suspended
) {
}
```

This is perfectly fine.

Because a DTO is:

```text
Data Transfer Object
```

Its job is to carry data.

Not enforce rules.

---

# Easy Rule to Remember

## DTO

```text
Carries data
```

Example:

```java
AccountResponse
OrderSummaryDto
```

---

## Anemic Domain Model

```text
Domain object with data
but no behavior
```

Example:

```java
getBalance()
setBalance()
```

---

## Rich Domain Model

```text
Domain object that owns
both data and behavior
```

Example:

```java
debit()
credit()
ship()
withdraw()
```

---

# Quick Comparison

| Topic                    | Anemic Model    | Rich Model               |
| ------------------------ | --------------- | ------------------------ |
| Rules Live In            | Services        | Domain Objects           |
| State Changes            | Through setters | Through business methods |
| Business Vocabulary      | Poor            | Rich                     |
| Risk of Rule Duplication | High            | Low                      |
| Invariant Protection     | Weak            | Strong                   |
| Domain Meaning           | Low             | High                     |

---

# One-Line Summary

A Rich Domain Model places business rules inside the objects that own the data, ensuring those rules cannot be forgotten or bypassed. An Anemic Domain Model places the rules in services while the entities become simple bags of data, making invariants harder to protect and business logic easier to duplicate.

# Putting It All Together: A Complete DDD Example

Before this chapter, we learned many concepts separately:

- Entity
- Value Object
- Aggregate
- Aggregate Root
- Domain Service
- Repository
- Business Rule
- Domain Event

A common question is:

> These concepts make sense individually, but how do they work together in a real application?

This document answers that question by walking through a complete online store checkout flow.

---

# The Business Scenario

Imagine an online store.

A customer wants to place an order.

Example:

```text
Customer: John

Basket:
- Laptop     $1000
- Mouse       $50

Total = $1050
```

When checkout happens, the system must:

```text
1. Verify customer is eligible.
2. Create an Order.
3. Calculate the total.
4. Submit the Order.
5. Save the Order.
6. Reserve inventory.
7. Send confirmation email.
8. Record an audit trail.
```

This single use case touches almost every DDD concept.

---

# How Most Systems Are Built

Many projects start like this:

```java
public class CheckoutService {

    public void checkout(...) {

        // load customer

        // check eligibility

        // calculate total

        // create order

        // change order status

        // save order

        // reserve inventory

        // send email

        // audit
    }
}
```

Everything sits inside one service.

Over time the service grows.

```text
100 lines
500 lines
1500 lines
```

Soon it knows:

```text
Customer rules
Order rules
Pricing rules
Inventory rules
Email rules
Audit rules
```

The domain objects become:

```java
Order
Customer
Product
```

with only:

```java
getters
setters
```

This is the exact problem DDD tries to solve.

---

# The DDD Version

Instead of placing everything into one service:

```text
Each object owns its own rules.
```

The service only coordinates.

---

# Step 1: Value Objects

Let's start with Money.

Money is not merely a number.

```text
100 USD
100 EUR
```

are not the same thing.

So we create a Value Object.

```java
public final class Money {

    private final BigDecimal amount;
    private final Currency currency;

    public Money add(Money other) {

        requireSameCurrency(other);

        return new Money(
                amount.add(other.amount),
                currency
        );
    }
}
```

Notice:

```text
Money protects Money rules.
```

Nobody can accidentally add:

```text
100 USD + 100 EUR
```

because the Value Object prevents it.

---

# Step 2: Entity

Now let's create an Order.

```java
Order
```

is an Entity because identity matters.

```text
Order #1001
Order #1002
```

Even if totals are identical,

they are different Orders.

---

# Step 3: Aggregate

The Order is not alone.

```text
Order
 + OrderLines
 + ShippingAddress
```

These belong together.

This becomes our Aggregate.

```text
Order Aggregate
```

---

# Step 4: Aggregate Root

The Order becomes the Aggregate Root.

```text
Order
 |
 +-- OrderLine
 +-- OrderLine
 +-- Address
```

All modifications go through Order.

Not directly to OrderLine.

---

# Step 5: Business Rules Live on the Aggregate

Business rule:

```text
Cannot submit an empty order.
```

The Order owns this rule.

```java
public void submit() {

    if(lines.isEmpty()) {
        throw new IllegalStateException(
            "Cannot submit empty order"
        );
    }

    status = SUBMITTED;
}
```

Notice:

```text
The rule lives exactly once.
```

No controller.

No UI.

No service remembers it.

Only the Order.

---

# Step 6: Customer Aggregate

Customer has its own rules.

Example:

```text
Blacklisted customer cannot checkout.
```

Customer owns that rule.

```java
public void requireEligible() {

    if(blacklisted) {
        throw new CustomerBlockedException();
    }
}
```

Again:

```text
Customer protects Customer rules.
```

---

# Step 7: Repository Loads Aggregates

Checkout requires:

```text
Customer Aggregate
Order Aggregate
```

Repositories provide them.

```java
Customer customer =
        customerRepository.find(
            customerId
        );
```

```java
Order order =
        orderRepository.find(
            orderId
        );
```

The service never writes:

```sql
SELECT * FROM ...
```

Repositories hide storage details.

---

# Step 8: Domain Service Coordinates

Checkout spans multiple aggregates.

It involves:

```text
Customer
Order
```

Therefore it belongs in a Domain Service.

```java
public class CheckoutService {

    public Order checkout(
            CustomerId customerId,
            Basket basket
    ) {

        Customer customer =
                customers.find(customerId);

        customer.requireEligible();

        Order order =
                Order.create(
                        customerId,
                        basket
                );

        order.submit();

        orders.save(order);

        return order;
    }
}
```

Notice what the service does NOT do.

```text
No blacklist rules.
No order validation rules.
No total calculation.
```

Those belong to their owners.

The service only coordinates.

---

# Step 9: Raising a Domain Event

After successful submission:

```text
Order was submitted.
```

That is a business fact.

We record it as an event.

```java
public record OrderSubmitted(
        OrderId orderId,
        CustomerId customerId,
        Money total
) {
}
```

Inside Order:

```java
public void submit() {

    if(lines.isEmpty()) {
        throw new IllegalStateException();
    }

    status = SUBMITTED;

    domainEvents.add(
            new OrderSubmitted(
                    id,
                    customerId,
                    total()
            )
    );
}
```

The Order records the fact.

Nothing more.

---

# Step 10: Event Gets Published

After commit:

```text
OrderSubmitted
```

is published.

```text
Order
   ↓
OrderSubmitted Event
   ↓
Event Bus
```

---

# Step 11: Consumers React

Inventory receives it.

```java
public void on(
        OrderSubmitted event
) {
    reserveInventory(
            event.orderId()
    );
}
```

Email receives it.

```java
public void on(
        OrderSubmitted event
) {
    sendConfirmation(
            event.customerId()
    );
}
```

Audit receives it.

```java
public void on(
        OrderSubmitted event
) {
    recordAudit(
            event.orderId()
    );
}
```

---

# Complete Request Flow

```text
Customer clicks Checkout
          |
          v
CheckoutService
          |
          |
          +--> CustomerRepository
          |
          +--> Customer.requireEligible()
          |
          +--> Order.create(...)
          |
          +--> Order.submit()
          |
          +--> OrderRepository.save()
          |
          v
OrderSubmitted Event
          |
          v
Event Bus
          |
          +--> Inventory Handler
          |
          +--> Email Handler
          |
          +--> Audit Handler
```

---

# Where Every DDD Concept Appears

| Concept        | Example                                    |
| -------------- | ------------------------------------------ |
| Value Object   | Money                                      |
| Entity         | Order, Customer                            |
| Aggregate      | Order + OrderLines                         |
| Aggregate Root | Order                                      |
| Business Rule  | Order.submit(), Customer.requireEligible() |
| Repository     | OrderRepository, CustomerRepository        |
| Domain Service | CheckoutService                            |
| Domain Event   | OrderSubmitted                             |
| Event Handler  | InventoryHandler, EmailHandler             |

---

# The Most Important Insight

Every concept has exactly one responsibility.

```text
Money
    protects money rules

Customer
    protects customer rules

Order
    protects order rules

CheckoutService
    coordinates aggregates

Repository
    loads aggregates

OrderSubmitted
    records a fact

Handlers
    react to the fact
```

No object does someone else's job.

That is why the model stays maintainable.

---

# Easy Way To Remember

```text
Value Object
    = What am I?

Entity
    = Who am I?

Aggregate
    = What must stay consistent together?

Domain Service
    = Rules about us.

Repository
    = Fetch and save us.

Domain Event
    = Something happened.
```

---

# One-Line Summary

A complete DDD model works because every concept has a single responsibility: Value Objects protect values, Aggregates protect business rules, Domain Services coordinate multiple Aggregates, Repositories load and save them, and Domain Events communicate important facts to the rest of the system.
