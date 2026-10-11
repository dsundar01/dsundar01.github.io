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

# Key Benefits

- Add features without modifying existing code
- Follow Open/Closed Principle (Open for extension, closed for modification)
- Flexible and reusable
- Avoids class explosion (no need for 100 pizza combinations)
