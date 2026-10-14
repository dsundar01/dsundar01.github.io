---
title: "Structural Design Pattern"
date: 2026-10-12 03:29:01 +05:30
categories: [LLD, Design Patterns, Structural]
tags: []
---

## Adapter Design Pattern

>> Composition + interface in adapter

>> Adpater must implement our interface and internally calls the legacy class.

### Existing Class (doesn't match your app interface)

```java
// Third-party / legacy class
public class SmsSender {

    public void sendSms(String mobileNumber, String message) {
        System.out.println("SMS sent to " + mobileNumber);
    }
}


// ❌ Client code — forced to handle incompatible APIs

public class AlertController {

    public void sendAlert(String type,
                          String destination,
                          String message) {

        if (type.equals("sms")) {

            SmsSender sms = new SmsSender();
            sms.sendSms(destination, message);

        } else if (type.equals("slack")) {

            SlackNotifier slack = new SlackNotifier();
            slack.sendSlackMessage(
                    destination,
                    message,
                    true); // ← different method, extra parameter

        }

        // ❌ Every new notification provider = new if/else
        // ❌ Different method names
        // ❌ Different parameter lists
        // ❌ Cannot treat all notifiers the same
        // ❌ Can't store them in List<NotificationService>
        // ❌ Hard to replace implementations in tests
    }
}
``
```

### Your Application Interface

```java
public interface NotificationService {
    void notify(String user, String message);
}
```

### Adapter

```java
public class SmsAdapter implements NotificationService {
    // >> Composition + interface
    private final SmsSender smsSender;

    public SmsAdapter(SmsSender smsSender) {
        this.smsSender = smsSender;
    }

    @Override
    public void notify(String user, String message) {

        // Convert user to mobile number
        String mobileNumber = UserRepository.getMobile(user);

        smsSender.sendSms(mobileNumber, message);
    }
}

```

### Usage

```java
NotificationService service =
        new SmsAdapter(new SmsSender());

service.notify("John", "Your order has been shipped");
```

### When Should You Actually Use This Pattern?

Not every problem needs an Adapter. Here's your decision-making guide:

### Perfect Use Cases

You need to reuse existing code that works great but has the wrong interface
You're integrating legacy systems where modifying source code is impossible or risky
You're working with third-party libraries that you don't control
You want to decouple your code from external service implementation details

## Decorator Design Pattern

Decorator: removes feature-bloating in the main class by wrapping behavior

- add behavior without subclass explosion  
- Removes feature bloating from main class
- Solves: dynamic feature addition

>> Composition + Interface  
>> Decorator is perfect when business rules are optional, combinable, and frequently changing.

```java
public interface Pizza {
    String getDescription();
    double getCost();
}


public class PlainPizza implements Pizza {
    @Override
    public String getDescription() {
        return "Plain Pizza";
    }
    @Override
    public double getCost() {
        return 5.0;
    }
}

// Decorator
public abstract class PizzaDecorator implements Pizza {
    // composition holds pizza
    protected Pizza pizza;
    public PizzaDecorator(Pizza pizza) {
        this.pizza = pizza;
    }
    public String getDescription() {
        return pizza.getDescription();
    }
    public double getCost() {
        return pizza.getCost();
    }
}

public class Cheese extends PizzaDecorator {
    public Cheese(Pizza pizza) {
        super(pizza);
    }
    @Override
    public String getDescription() {
        return pizza.getDescription() + ", Cheese";
    }
    @Override
    public double getCost() {
        return pizza.getCost() + 1.5;
    }
}


public class Mushroom extends PizzaDecorator {
    public Mushroom(Pizza pizza) {
        super(pizza);
    }
    @Override
    public String getDescription() {
        return pizza.getDescription() + ", Mushroom";
    }
    @Override
    public double getCost() {
        return pizza.getCost() + 1.0;
    }
}

public class Olives extends PizzaDecorator {
    public Olives(Pizza pizza) {
        super(pizza);
    }
    @Override
    public String getDescription() {
        return pizza.getDescription() + ", Olives";
    }
    @Override
    public double getCost() {
        return pizza.getCost() + 1.2;
    }
}

public class DecoratorDesignPatternDemo {
    public static void main(String[] args) {
        Pizza pizza = new PlainPizza();// actual pizza with cost
        // adding toppins
        pizza = new Cheese(pizza);
        pizza = new Mushroom(pizza);
        pizza = new Olives(pizza);
        System.out.println("Order: " + pizza.getDescription());
        System.out.println("Total Cost: $" + pizza.getCost());
    }
}
Output:
Order: Plain Pizza, Cheese, Mushroom, Olives
Total Cost: $8.7



```

### Key Benefits

- Add features without modifying existing code
- Follow Open/Closed Principle (Open for extension, closed for modification)
- Flexible and reusable
- Avoids class explosion (no need for 100 pizza combinations)

>> Decorator pattern - passing an object inside a object which will add itself + passed one.

## Proxy Pattern

- The Proxy design pattern is a structural design pattern that **puts a stand-in object in front of a real object** to control access to it. It is used for lazy loading, security checks, caching, logging, and remote calls — without changing the client or the real object.
- Imagine you want to meet a celebrity. You don’t walk straight to them. You go through their manager.before any meeting actually reaches the celebrity, the manager checks if you’re allowed, if it’s the right time, or if a cached answer (“not available this week”) will do

>> The manager is the proxy. The celebrity is the real subject. You — the client.

### The Code — Lazy Image Loader

```java
// Both the real object and the proxy implement this
public interface Image {
  void display();
}

// The actual heavy object - loading is expensive
public class RealImage implements Image {

  private final String filename;

  public RealImage(String filename) {
    this.filename = filename;
    loadFromDisk(); // expensive operation
  }

  private void loadFromDisk() {
    System.out.println("Loading " + filename + " from disk…");
  }

  @Override
  public void display() {
    System.out.println("Displaying " + filename);
  }
}

// Proxy - same interface, controls access to RealImage
public class ProxyImage implements Image {

  private final String filename;
   // Composition + interface
  private RealImage realImage; // created lazily

  public ProxyImage(String filename) {
    this.filename = filename;
  }

  @Override
  public void display() {
    // Create the real object ONLY when actually needed
    if (realImage == null) {
      realImage = new RealImage(filename);
    }
    realImage.display();
  }
}

public class Gallery {

  public static void main(String[] args) {
    // Creating the proxy is cheap - no disk loading yet
    Image image = new ProxyImage("photo.jpg");
    System.out.println("Proxy created. Disk not touched yet.\n");
    // First call - proxy loads the real image
    image.display();
    System.out.println();
    // Second call - real image already cached inside proxy
    image.display();
  }
}

```

### What Just Happened?

Without Proxy: new RealImage(“photo.jpg”) → loads from disk immediately

With Proxy: new ProxyImage(“photo.jpg”) → loads from disk only on first display()

The client code never changed. It still talks to an `Image`. But the proxy decided when the real work happens — and made sure it happens only once.

Swap the lazy-loading logic for an auth check and you get a Protection Proxy. Swap it for a network call and you get a Remote Proxy. Same skeleton, different intent.

## When to Use the Proxy Design Pattern

Reach for a proxy when you need to:

1. Defer expensive object creation until it’s truly needed (virtual proxy)
2. Add access control without polluting the real object with auth logic (protection proxy)
3. Talk to a remote service as if it were local (remote proxy)
4. Cache results of expensive operations transparently (caching proxy)
5. Add cross-cutting concerns like logging, metrics, or transactions (AOP-style proxies)
6. Avoid it when a simple method call or a decorator would do the job — proxies add an extra layer of indirection, and indirection has a cost.

⚡ Top 4 Interview Use Cases

1. API Gateway / Rate Limiter: Intercepts incoming network calls to check client permissions and enforce traffic limits before routing to microservices.
2. Database Cache Wrapper: Sits in front of a heavy database. Checks an in-memory cache (like Redis) first; hits the real DB only on a cache miss.
3. Lazy-Loading Media Streamer: Loads lightweight placeholder thumbnails instantly. Only instantiates and fetches heavy video streams when a user clicks "Play".
4. Secure Code Sandbox (LeetCode style): Acts as a protective shield around system execution, blocking untrusted user code from making dangerous system or network calls.

⚖️ Trade-offs
  
• Pros:  
 • Open/Closed Principle: Introduce new proxies (logging, caching, security) without altering the client or the real object's code.  
 • Separation of Concerns: Keeps core business logic clean of system-level plumbing (like caching or auditing).

• Cons:  
• Latency: Adds an extra layer of indirection, which can slightly delay response times.  
• Complexity: Increases the overall class count in your codebase.

## Bridge Pattern: Real Purpose

The **Bridge Pattern** is used when:

- Two or more dimensions can change independently.
- Using inheritance would create a combinatorial explosion of subclasses.

## Famous Real-World Example: Notification System

Suppose you are building an alert system.

There are two independent dimensions.

### Dimension 1: Notification Type

- Promotion
- OTP
- Order Update

### Dimension 2: Sending Channel

- Email
- SMS
- Push Notification

## Without the Bridge Pattern

You may start creating classes such as:

```text
PromotionEmailNotification
PromotionSMSNotification
PromotionPushNotification

OTPEmailNotification
OTPSMSNotification
OTPPushNotification

OrderEmailNotification
OrderSMSNotification
OrderPushNotification
```

The number of classes quickly grows.

This is known as the **Cartesian Product Problem**.

For example, if you have:

- 5 notification types
- 4 sending channels

You may need:

```text
5 x 4 = 20 classes
```

📊 Bridge Pattern Cheat Sheet Summary

Based on the brilliant example you shared, here are the core takeaways for your LLD notes:  

• The Problem: The Cartesian Product Problem (Combinatorial Explosion of Subclasses). If you have \(N\) abstractions and \(M\) implementations, inheritance forces you to create \(N * M\) classes.

• The Solution: The Bridge Pattern splits them into two separate hierarchies. You only need to write \(N + M\) classes.

• The Bridge: The protected NotificationSender sender; reference inside the abstract class acts as the literal bridge connecting the two dimensions.

## Bridge Pattern Solution

Separate:

- **WHAT** the notification is
- **HOW** the notification is sent

These two dimensions can then evolve independently.

## Step 1: Implementor Hierarchy

Create an abstraction for the sending channel.

```java
interface NotificationSender {
    void send(String message);
}
```

Create concrete channel implementations.

```java
class EmailSender implements NotificationSender {

    @Override
    public void send(String message) {
        System.out.println("Email: " + message);
    }
}
```

```java
class SMSSender implements NotificationSender {

    @Override
    public void send(String message) {
        System.out.println("SMS: " + message);
    }
}
```

```java
class PushNotificationSender implements NotificationSender {

    @Override
    public void send(String message) {
        System.out.println("Push Notification: " + message);
    }
}
```

## Step 2: Abstraction Hierarchy

Create the notification abstraction.

```java
abstract class Notification {

    protected NotificationSender sender;

    protected Notification(NotificationSender sender) {
        this.sender = sender;
    }

    abstract void notifyUser();
}
```

The `Notification` class does not know the concrete sending mechanism. It depends only on the `NotificationSender` abstraction.

This connection between the two hierarchies is the **bridge**.

## Step 3: Refined Abstractions

Create the concrete notification types.

```java
class OTPNotification extends Notification {

    public OTPNotification(NotificationSender sender) {
        super(sender);
    }

    @Override
    void notifyUser() {
        sender.send("Your OTP is 1234");
    }
}
```

```java
class PromotionNotification extends Notification {

    public PromotionNotification(NotificationSender sender) {
        super(sender);
    }

    @Override
    void notifyUser() {
        sender.send("Big sale today!");
    }
}
```

```java
class OrderUpdateNotification extends Notification {

    public OrderUpdateNotification(NotificationSender sender) {
        super(sender);
    }

    @Override
    void notifyUser() {
        sender.send("Your order has been shipped.");
    }
}
```

## Usage

Send an OTP through email:

```java
NotificationSender sender = new EmailSender();
Notification notification = new OTPNotification(sender);

notification.notifyUser();
```

Output:

```text
Email: Your OTP is 1234
```

Send the same OTP through SMS:

```java
Notification notification =
        new OTPNotification(new SMSSender());

notification.notifyUser();
```

Output:

```text
SMS: Your OTP is 1234
```

Send a promotion through push notification:

```java
Notification notification =
        new PromotionNotification(new PushNotificationSender());

notification.notifyUser();
```

No new combination-specific subclass is required.

## What the Bridge Pattern Solved

Instead of creating:

```text
OTPEmailNotification
OTPSMSNotification
OTPPushNotification
```

we combine the two dimensions dynamically:

```text
Notification + NotificationSender
```

For example:

```java
new OTPNotification(new EmailSender());
new OTPNotification(new SMSSender());
new OTPNotification(new PushNotificationSender());
```

Both hierarchies can grow independently.

### Add a New Notification Type

```java
class PaymentNotification extends Notification {

    public PaymentNotification(NotificationSender sender) {
        super(sender);
    }

    @Override
    void notifyUser() {
        sender.send("Your payment was successful.");
    }
}
```

### Add a New Sending Channel

```java
class WhatsAppSender implements NotificationSender {

    @Override
    public void send(String message) {
        System.out.println("WhatsApp: " + message);
    }
}
```

Use them together without introducing a `PaymentWhatsAppNotification` subclass:

```java
Notification notification =
        new PaymentNotification(new WhatsAppSender());
```

## Key Interview Signal

Consider the Bridge Pattern when the interviewer says:

> These two things may grow or change independently.

Typical indicators include:

- Multiple independent dimensions
- Too many subclasses for every possible combination
- A need to switch implementations dynamically
- A requirement to extend one dimension without modifying the other

## Example with Three Dimensions

Suppose you are designing a video streaming system.

### Dimension 1: Content Type

- Movie
- Sports
- Kids Content

### Dimension 2: Streaming Quality

- 720p
- 1080p
- 4K

### Dimension 3: Device

- Mobile
- TV
- Laptop

## Without Composition

Inheritance may produce classes such as:

```text
Movie720pMobilePlayer
Movie720pTVPlayer
Movie4KTVPlayer
Sports1080pMobilePlayer
KidsContent4KLaptopPlayer
...
```

For three content types, three quality levels, and three devices, inheritance may require:

```text
3 x 3 x 3 = 27 combinations
```

This design becomes difficult to maintain as new dimensions and options are added.

## Better Design

Separate each dimension:

```text
Content
QualityStrategy
DeviceRenderer
```

Then compose them dynamically:

```java
VideoPlayer player = new VideoPlayer(
        new MovieContent(),
        new FourKQuality(),
        new TVRenderer()
);
```

The exact class structure may vary, but the core idea remains the same: avoid creating a subclass for every possible combination.

## Important Insight

The Bridge Pattern fundamentally says:

> Do not multiply independent dimensions using inheritance. Compose them dynamically instead.

Inheritance creates combinations at the class level:

```text
NotificationType x SendingChannel
```

Bridge keeps the dimensions separate and connects them using composition:

```text
Notification has a NotificationSender
```

## One-Line Summary

> The Bridge Pattern prevents class explosion caused by multiple independent variations by separating those dimensions and composing them dynamically.

## MultiDimensional Bridge

- To make this work seamlessly, you choose one core dimension to act as the primary structural anchor (The Abstraction), and you treat the other dimensions as pluggable behavioral strategies (The Implementations).

🎭 1. The Abstraction (The Structural Anchor)

Dimension 1: Content Type (Movie, Sports, KidsContent)

• Why? Content is the core entity that the business logic revolves around. It holds the metadata (title, duration), handles user access/licensing, and defines what is actually being watched.
• The Code Role: This forms your main class hierarchy. The base abstract class (Content) will act as the structural anchor by holding references to the other dimensions.

⚙️ 2. The Implementations (The Pluggable Strategies)

Dimensions 2 and 3 are decoupled into independent interface hierarchies. The abstraction delegates the technical work to them via composition.
• Dimension 2: QualityStrategy (720p, 1080p, 4K)
 • Role: Implementation of bitrate, parsing, and data streaming.
 • Responsibility: It handles the math of pulling the correct chunk size from the server based on the resolution.
• Dimension 3: DeviceRenderer (Mobile, TV, Laptop)
 • Role: Implementation of UI decoding and hardware rendering.
 • Responsibility: It handles the platform-specific code (e.g., Android ExoPlayer views vs. Smart TV webOS video tags) to draw the pixels on the physical screen.

🛠️ Visualizing the Architecture in Code

By assigning these roles, you eliminate the combinatorial class explosion (3 × 3 × 3 = 27 classes) and reduce it to a clean, flat structure of just 9 classes (3 + 3 + 3).

```java
// --- IMPLEMENTATION DIMENSION A: Quality ---
interface QualityStrategy { void streamData(); }
class HighDefinition4K implements QualityStrategy { public void streamData() { /*Stream 25Mbps*/ } }

// --- IMPLEMENTATION DIMENSION B: Device ---
interface DeviceRenderer { void renderVideo(); }
class TVRenderer implements DeviceRenderer { public void renderVideo() { /*HW Decode for TV*/ } }

// --- THE CORE ABSTRACTION ---
abstract class Content {
    protected QualityStrategy quality; // Bridge/Composition 1
    protected DeviceRenderer device;   // Bridge/Composition 2

    public Content(QualityStrategy quality, DeviceRenderer device) {
        this.quality = quality;
        this.device = device;
    }
    abstract void play();
}

// --- REFINED ABSTRACTION ---
class SportsContent extends Content {
    public SportsContent(QualityStrategy q, DeviceRenderer d) { super(q, d); }

    void play() {
        System.out.println("Fetching Live Sports feeds...");
        quality.streamData();  // Delegates streaming mechanism
        device.renderVideo();  // Delegates rendering mechanism
    }
}
```

💡 Core Takeaway for Interviews

When dealing with multi-dimensional LLD problems:

1. Identify the "Noun" / Main Domain Entity → Make it the Abstraction.
2. Identify the "Verbs" / Technical Variations (How to stream, where to render) → Make them the Implementations via the Strategy/Bridge approach.

### 🚀 Let's add a 4th Dimension: Audio Format

```java

// 
Step 1: Create the new Implementation Hierarchy

// Completely independent 4th dimension
interface AudioProcessor {
    void processAudio();
}
class DolbyAtmosProcessor implements AudioProcessor {
    public void processAudio() { System.out.println("Processing 7.1 Surround Sound..."); }
}
class StereoProcessor implements AudioProcessor {
    public void processAudio() { System.out.println("Processing 2.0 Stereo Sound..."); }
}


/*
Step 2: Inject the new reference into the Abstraction

You only modify the base abstract class to accept the new dimension. Your existing concrete content classes (Movie, Sports) just pass it up to the parent constructor.*/

abstract class Content {
    protected QualityStrategy quality;
    protected DeviceRenderer device;
    protected AudioProcessor audio; // 🌟 Just add the new reference here!

    public Content(QualityStrategy quality, DeviceRenderer device, AudioProcessor audio) {
        this.quality = quality;
        this.device = device;
        this.audio = audio;
    }
    abstract void play();
}

```
