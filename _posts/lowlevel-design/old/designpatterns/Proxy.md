# Proxy Pattern

## CAUSE and EFFECT

```
CAUSE (the technique):
"Place a substitute object (proxy) in front of the real object
to control access to it"

EFFECT (the benefit):
"Client code stays unchanged while the proxy adds access control,
lazy loading, caching, logging, or remote access transparently"
```

## The Problem in Normal Code

Suppose you build an **image gallery** that loads high-resolution images from disk.

```java
class HighResImage {
    private String filename;
    private byte[] data;  // 50 MB loaded from disk

    HighResImage(String filename) {
        this.filename = filename;
        this.data = loadFromDisk(filename);  // EXPENSIVE — happens immediately
        System.out.println("Loaded " + filename + " (50 MB)");
    }

    void display() {
        System.out.println("Displaying " + filename);
    }

    private byte[] loadFromDisk(String filename) {
        // Simulate expensive disk read
        return new byte[50_000_000];
    }
}
```

Client code:

```java
// Gallery has 100 images
List<HighResImage> gallery = new ArrayList<>();
gallery.add(new HighResImage("photo1.jpg"));  // loads 50 MB immediately
gallery.add(new HighResImage("photo2.jpg"));  // loads 50 MB immediately
gallery.add(new HighResImage("photo3.jpg"));  // loads 50 MB immediately
// ... 97 more — 5 GB loaded at startup!

// User only looks at photo1
gallery.get(0).display();
// The other 99 images were loaded for nothing
```

**What goes wrong:**

- All 100 images load at startup — 5 GB of memory used immediately
- User may only view 2-3 images — 97 loaded for nothing
- Startup is extremely slow
- If you want to add access control (only admin sees certain images), you must change `HighResImage` itself
- If you want to log every access, you must change `HighResImage` itself
- If the image is on a remote server, the client must handle networking itself

## Three Approaches

**AP1:** Load everything eagerly — simple but wastes memory and time.

**AP2:** Add lazy loading, caching, and access control directly inside the real class — violates Single Responsibility, clutters the real class with non-core concerns.

**AP3:** Use Proxy pattern — a stand-in object controls access to the real object. The real class stays clean. The client doesn't know it's talking to a proxy.

## The Key Insight

The proxy and the real object implement the **same interface**. The client cannot tell the difference. The proxy intercepts the call and decides what to do before/after delegating to the real object.

```
Without Proxy:
Client ──────────> RealObject

With Proxy:
Client ──────────> Proxy ──────────> RealObject
                    |
                 controls access:
                 lazy load / cache / check permissions / log
```

## Types of Proxy

Type | What it controls | Example
-- | -- | --
Virtual Proxy | Lazy loading — delays creation of expensive object until needed | Image loads only when displayed
Protection Proxy | Access control — checks permissions before allowing access | Admin-only operations
Caching Proxy | Caching — stores results to avoid repeated expensive calls | Database query cache
Logging Proxy | Logging — records every access to the real object | Audit trail
Remote Proxy | Remote access — represents an object on another server | RMI stub

## Implementation — Virtual Proxy (Lazy Loading)

### Step 1: Common interface

```java
interface Image {
    void display();
}
```

### Step 2: Real object (heavy, expensive)

```java
class HighResImage implements Image {
    private String filename;
    private byte[] data;

    HighResImage(String filename) {
        this.filename = filename;
        this.data = loadFromDisk(filename);  // expensive
        System.out.println("Loaded " + filename + " from disk");
    }

    public void display() {
        System.out.println("Displaying " + filename);
    }

    private byte[] loadFromDisk(String filename) {
        return new byte[50_000_000];  // simulate 50 MB
    }
}
```

### Step 3: Proxy — same interface, controls when real object is created

```java
class ImageProxy implements Image {
    private String filename;
    private HighResImage realImage;  // null until needed

    ImageProxy(String filename) {
        this.filename = filename;
        // does NOT load the image here — that's the whole point
    }

    public void display() {
        if (realImage == null) {
            realImage = new HighResImage(filename);  // load only when needed
        }
        realImage.display();
    }
}
```

### Step 4: Client code — unchanged, uses same interface

```java
// Gallery uses proxies — NO images loaded yet
List<Image> gallery = new ArrayList<>();
gallery.add(new ImageProxy("photo1.jpg"));  // no disk read
gallery.add(new ImageProxy("photo2.jpg"));  // no disk read
gallery.add(new ImageProxy("photo3.jpg"));  // no disk read
// ... 97 more — 0 MB used at startup

// User views photo1 — ONLY photo1 loads
gallery.get(0).display();  // "Loaded photo1.jpg from disk" then "Displaying photo1.jpg"

// User views photo1 again — already loaded, no reload
gallery.get(0).display();  // "Displaying photo1.jpg" (cached)

// photo2 and photo3 never loaded — memory saved
```

## Before vs After

**Before (without Proxy):**

```java
// All 100 images loaded at startup = 5 GB
List<HighResImage> gallery = new ArrayList<>();
gallery.add(new HighResImage("photo1.jpg"));  // 50 MB loaded
gallery.add(new HighResImage("photo2.jpg"));  // 50 MB loaded
// ... startup takes forever
```

**After (with Proxy):**

```java
// 0 images loaded at startup = 0 MB
List<Image> gallery = new ArrayList<>();
gallery.add(new ImageProxy("photo1.jpg"));  // lightweight proxy
gallery.add(new ImageProxy("photo2.jpg"));  // lightweight proxy
// ... startup is instant, images load on demand
```

## Implementation — Protection Proxy (Access Control)

```java
interface Document {
    void view();
    void edit(String content);
}

class RealDocument implements Document {
    private String name;
    private String content;

    RealDocument(String name, String content) {
        this.name = name;
        this.content = content;
    }

    public void view() {
        System.out.println("Viewing: " + content);
    }

    public void edit(String content) {
        this.content = content;
        System.out.println("Edited: " + name);
    }
}

class ProtectionProxy implements Document {
    private RealDocument realDoc;
    private String userRole;

    ProtectionProxy(RealDocument realDoc, String userRole) {
        this.realDoc = realDoc;
        this.userRole = userRole;
    }

    public void view() {
        realDoc.view();  // everyone can view
    }

    public void edit(String content) {
        if ("ADMIN".equals(userRole)) {
            realDoc.edit(content);
        } else {
            System.out.println("Access denied. Only ADMIN can edit.");
        }
    }
}
```

```java
Document adminDoc = new ProtectionProxy(new RealDocument("report", "data"), "ADMIN");
adminDoc.edit("new data");  // works

Document viewerDoc = new ProtectionProxy(new RealDocument("report", "data"), "VIEWER");
viewerDoc.edit("hack");     // "Access denied. Only ADMIN can edit."
viewerDoc.view();           // works
```

## Implementation — Caching Proxy

```java
interface DatabaseService {
    String query(String sql);
}

class RealDatabaseService implements DatabaseService {
    public String query(String sql) {
        System.out.println("Executing expensive query: " + sql);
        // simulate slow DB call
        return "result for: " + sql;
    }
}

class CachingProxy implements DatabaseService {
    private RealDatabaseService realService;
    private Map<String, String> cache = new HashMap<>();

    CachingProxy(RealDatabaseService realService) {
        this.realService = realService;
    }

    public String query(String sql) {
        if (cache.containsKey(sql)) {
            System.out.println("Cache hit for: " + sql);
            return cache.get(sql);
        }
        String result = realService.query(sql);
        cache.put(sql, result);
        return result;
    }
}
```

```java
DatabaseService db = new CachingProxy(new RealDatabaseService());
db.query("SELECT * FROM users");  // hits DB
db.query("SELECT * FROM users");  // cache hit — no DB call
db.query("SELECT * FROM orders"); // hits DB
```

## Where Is the Proxy?

```java
class ImageProxy implements Image {
    private HighResImage realImage;  // <-- reference to real object

    public void display() {
        // PROXY LOGIC: lazy load, cache, check access, log, etc.
        if (realImage == null) {
            realImage = new HighResImage(filename);
        }
        // DELEGATION: forward to real object
        realImage.display();
    }
}
```

The proxy:
1. Implements the SAME interface as the real object
2. Holds a REFERENCE to the real object
3. INTERCEPTS calls and adds control logic
4. DELEGATES to the real object when appropriate

## Real Examples

Example | Proxy type | Real object | What proxy controls
-- | -- | -- | --
Image gallery | Virtual | HighResImage | Lazy loading
Admin document | Protection | RealDocument | Permission check
DB query | Caching | DatabaseService | Cache results
API call logging | Logging | APIService | Log every request
Remote service | Remote | RemoteServer | Network communication
Hibernate entity | Virtual | Database entity | Lazy-load related objects

**Java/JDK usage:**

- `java.lang.reflect.Proxy` — dynamic proxy creation at runtime:
```java
// Creates a proxy that implements any interface at runtime
Object proxy = Proxy.newProxyInstance(
    classLoader,
    new Class[]{ MyInterface.class },
    (proxyObj, method, args) -> {
        System.out.println("Before: " + method.getName());
        Object result = method.invoke(realObject, args);
        System.out.println("After: " + method.getName());
        return result;
    }
);
```

- **Spring AOP** — uses proxies for `@Transactional`, `@Cacheable`, `@Secured`:
```java
@Transactional  // Spring creates a proxy that wraps this method with transaction logic
public void transferMoney(Account from, Account to, double amount) {
    // your code — no transaction handling here
    // the proxy handles begin/commit/rollback
}
```

- **Hibernate lazy loading** — entity relationships use proxies:
```java
@OneToMany(fetch = FetchType.LAZY)
private List<Order> orders;  // Hibernate creates a proxy, loads orders only when accessed
```

## Design Principles

Principle | How Proxy uses it
-- | --
Single Responsibility | Real object handles core logic. Proxy handles access control/caching/lazy loading separately.
Open/Closed | Add new behavior (logging, caching) without modifying the real class
Liskov Substitution | Proxy implements the same interface, so it can replace the real object anywhere
Program to interface | Client depends on Image interface, not HighResImage or ImageProxy
Separation of Concerns | Cross-cutting concerns (security, caching, logging) live in the proxy, not in business logic

## Comparison with Other Patterns

### Proxy vs Decorator

```
STRUCTURALLY: Almost identical — both wrap an object with the same interface

INTENT:
Proxy: CONTROLS ACCESS to the real object (lazy load, permission, cache)
Decorator: ADDS NEW BEHAVIOR to the real object (new features)

Proxy: client usually doesn't know it's using a proxy
Decorator: client often explicitly wraps objects

Proxy: typically wraps ONE specific real object
Decorator: typically stackable — multiple decorators chained
```

```
PROXY (controls access):
Client → ImageProxy → HighResImage
          (delays creation until needed)

DECORATOR (adds behavior):
Client → BufferedInputStream → FileInputStream
          (adds buffering capability)
```

### Proxy vs Adapter

```
Proxy: SAME interface as real object. Controls access.
Adapter: DIFFERENT interface. Converts one interface to another.

Proxy: Image → ImageProxy → HighResImage (same interface)
Adapter: NewAPI → Adapter → OldAPI (different interfaces)
```

### Proxy vs Facade

```
Proxy: wraps ONE object, same interface, controls access
Facade: wraps MANY objects, DIFFERENT (simpler) interface, simplifies access

Proxy: one-to-one
Facade: one-to-many
```

### Proxy vs Flyweight

```
Proxy: adds indirection to control access to one object
Flyweight: shares one object across many clients to save memory

Proxy: about control
Flyweight: about memory
```

## The Progression Story (for interviews)

Step | What happens | Problem
-- | -- | --
1 | Client uses real object directly | Works fine for simple cases
2 | Object is expensive to create or load | Startup is slow, memory wasted
3 | Need access control, logging, or caching | Adding it to real class violates SRP
4 | Use Proxy: same interface, intercepts calls, delegates to real object | Real class stays clean, behavior added transparently

## Quick Reference

Question | Answer
-- | --
What problem does it solve? | Need to control access to an object (lazy load, permissions, cache, logging, remote) without changing its code
What is the proxy? | A stand-in object that implements the same interface as the real object
What does the proxy do? | Intercepts calls, adds control logic, then delegates to the real object
Does the client know it's a proxy? | No. It uses the same interface as the real object.
Virtual Proxy | Delays creation of expensive object until first use
Protection Proxy | Checks permissions before forwarding calls
Caching Proxy | Stores results to avoid repeated expensive calls
Key rule | Proxy implements the same interface as the real object and holds a reference to it
How is it different from Decorator? | Proxy controls access. Decorator adds new behavior. Same structure, different intent.
How is it different from Adapter? | Proxy uses same interface. Adapter converts between different interfaces.
Java example | java.lang.reflect.Proxy, Spring @Transactional/@Cacheable, Hibernate lazy loading
Interview one-liner | Proxy pattern provides a substitute object with the same interface as the real object, controlling access through lazy loading, caching, permission checks, or logging — transparently to the client.
