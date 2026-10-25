# Bridge Pattern

## What it solves
Class explosion caused by multiple independent variations.

## Example Scenario
Alert system with:
- Notification Types: Promotion, OTP, Order Update
- Sending Channels: Email, SMS, Push Notification

## Three Approaches

**AP1:** Use if/else to select the logic — giant if/else block.

**AP2:** Use Strategy pattern to isolate logic — class explosion due to multi-dimension combinations.

**AP3:** Use Bridge pattern — separates Abstraction from Implementation so both can evolve independently.

## Without Bridge: Inheritance Explosion

```
OTPEmailNotification
OTPSMSNotification
OTPPushNotification
PromotionEmailNotification
PromotionSMSNotification
PromotionPushNotification
OrderUpdateEmailNotification
OrderUpdateSMSNotification
OrderUpdatePushNotification
```

3 types x 3 channels = 9 classes.
Add one more channel? 3 more classes. Add one more type? 3 more classes.

## With Bridge: Composition

3 notification types + 3 senders = 6 classes.
Add a new channel? Just 1 new sender class. Add a new notification type? Just 1 new notification class.

## Core Insight

Do not multiply dimensions using inheritance. Instead, compose dimensions dynamically.

## How to Decide Abstraction vs Implementation

- Abstraction = the thing the client talks to = the "what" = business concept
- Implementation = the thing that does the low-level work = the "how" = platform/channel/mechanism

In this example:
- Client says "Send an OTP notification" → that is the what → Abstraction
- How it gets sent (email, SMS, push) → that is the how → Implementation

## Diagram

```
ABSTRACTION SIDE              IMPLEMENTATION SIDE
----------------              -------------------
Notification                  MessageSender (interface)
   |                             |
OTPNotification               EmailSender
PromotionNotification         SMSSender
OrderUpdateNotification       PushSender

Notification ---holds-a-reference-to---> MessageSender
                    THE BRIDGE
```

## Implementation

### Step 1: Implementation Side (the "how")

```java
interface MessageSender {
    void send(String message, String recipient);
}

class EmailSender implements MessageSender {
    public void send(String message, String recipient) {
        System.out.println("Email to " + recipient + ": " + message);
    }
}

class SMSSender implements MessageSender {
    public void send(String message, String recipient) {
        System.out.println("SMS to " + recipient + ": " + message);
    }
}

class PushSender implements MessageSender {
    public void send(String message, String recipient) {
        System.out.println("Push to " + recipient + ": " + message);
    }
}
```

### Step 2: Abstraction Side (the "what") — holds a reference to the implementation

```java
abstract class Notification {
    protected MessageSender sender;  // <-- THIS IS THE BRIDGE

    Notification(MessageSender sender) {
        this.sender = sender;
    }

    abstract void notify(String recipient);
}

class OTPNotification extends Notification {
    private String otp;

    OTPNotification(MessageSender sender, String otp) {
        super(sender);
        this.otp = otp;
    }

    void notify(String recipient) {
        sender.send("Your OTP is: " + otp, recipient);
    }
}

class PromotionNotification extends Notification {
    private String offer;

    PromotionNotification(MessageSender sender, String offer) {
        super(sender);
        this.offer = offer;
    }

    void notify(String recipient) {
        sender.send("Promotion: " + offer, recipient);
    }
}

class OrderUpdateNotification extends Notification {
    private String orderId;

    OrderUpdateNotification(MessageSender sender, String orderId) {
        super(sender);
        this.orderId = orderId;
    }

    void notify(String recipient) {
        sender.send("Order " + orderId + " has been shipped", recipient);
    }
}
```

### Step 3: Client composes them freely

```java
// OTP via SMS
new OTPNotification(new SMSSender(), "4829").notify("user@phone");

// OTP via Email
new OTPNotification(new EmailSender(), "4829").notify("user@mail.com");

// Promotion via Push
new PromotionNotification(new PushSender(), "50% off").notify("user123");

// Order update via Email
new OrderUpdateNotification(new EmailSender(), "ORD-991").notify("user@mail.com");
```

## Where is the Bridge?

The field `protected MessageSender sender` inside `Notification` is the bridge. It connects the two hierarchies through composition, not inheritance.

## Multi-Dimension Case (3+ dimensions)

Add a third dimension: Urgency (normal, urgent, critical).

Without patterns: 3 types x 3 channels x 3 urgencies = 27 classes.
With Bridge: 3 types + 3 senders + 2 urgencies = 8 classes.

```java
interface UrgencyPolicy {
    String wrap(String message);
}

class NormalUrgency implements UrgencyPolicy {
    public String wrap(String message) { return message; }
}

class CriticalUrgency implements UrgencyPolicy {
    public String wrap(String message) { return "CRITICAL: " + message; }
}
```

Abstraction holds two bridges:

```java
abstract class Notification {
    protected MessageSender sender;
    protected UrgencyPolicy urgency;

    Notification(MessageSender sender, UrgencyPolicy urgency) {
        this.sender = sender;
        this.urgency = urgency;
    }

    abstract void notify(String recipient);
}

class OTPNotification extends Notification {
    private String otp;

    OTPNotification(MessageSender sender, UrgencyPolicy urgency, String otp) {
        super(sender, urgency);
        this.otp = otp;
    }

    void notify(String recipient) {
        sender.send(urgency.wrap("Your OTP is: " + otp), recipient);
    }
}
```

Usage:

```java
// Critical OTP via SMS
new OTPNotification(new SMSSender(), new CriticalUrgency(), "4829").notify("user");

// Normal promotion via Email
new PromotionNotification(new EmailSender(), new NormalUrgency(), "50% off").notify("user");
```

## Quick Reference

| Question | Answer |
|---|---|
| Which dimension is abstraction? | The business concept the client interacts with (notification type) |
| Which dimension is implementation? | The mechanism/channel that does the work (sender) |
| Where is the bridge? | The field in abstraction that holds the implementation reference |
| How does it prevent class explosion? | Composition instead of inheritance across dimensions |
| Multi-dimension? | Add more composed fields, one per dimension |
| Key rule | Each independently varying dimension gets its own interface hierarchy, connected by composition |

---

Ready to paste.
