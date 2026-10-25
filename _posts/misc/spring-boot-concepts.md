## Spring Boot Concepts

Spring Boot simplifies Spring application setup by reducing manual configuration and providing sensible defaults.

<details>
<summary><b>IOC (Inversion of Control)</b></summary>

- IoC is the concept; Dependency Injection is the pattern Spring Boot uses to implement it through the Spring container.

IOC 
- Spring creates objects instead of programmers (inversing the control)
- create, manage, inject dependencies & lifecyle
- BeanFactory and ApplicationContext are both Spring IoC containers.

- BeanFactory provides basic bean creation and dependency injection.
- ApplicationContext extends BeanFactory and adds enterprise features like events, profiles, message resolution, and resource loading.
- Spring Boot uses ApplicationContext internally.

</details>

<details>
<summary><b>Dependency Injection</b></summary>

- object get dependency from external source rather than creating inside code
- loose coupling -> send different polymorphised class
1. Setter Injection - mutable object
2. Constructor Injection - immutable objects since we use final keyword (which will called in constructor only )
3. Autowired -> special characters?

</details>

<details>
<summary><b>@Component</b></summary>

- mark spring class as spring manage bean
- NonUniqueBeanException
    1. @Primary
    2. @Qualifier
    3. @Component("jio") + @Qualifier("jio")


</details>

<details>
<summary><b>Bean Scope</b></summary>

- Bean scope defines how long a bean lives and how many objects Spring creates.

1. Singleton
    - only one object in the Spring container
    - use when: bean is stateless and shared, like service, repository, logging helper
    - real world case: `UserService`, `OrderRepository`, or a shared `EmailValidator`

2. Prototype
    - new object every time the bean is requested
    - use when: you need a fresh object each time and the bean holds temporary state
    - real world case: report builder, invoice generator object, or a temporary workflow object

3. Request
    - one object per HTTP request
    - use when: data should live only for a single web request
    - real world case: storing request-specific audit data like request id, client ip, and request start time

4. Session
    - one object per user session
    - use when: you need user-specific data across multiple requests, like cart or login flow data
    - real world case: shopping cart, multi-step checkout form, or user theme/language preference

5. Application
    - one object for the whole web application
    - use when: data should be shared across the full application
    - real world case: application-wide cache metadata, maintenance mode flag, or shared feature toggle snapshot

6. Custom Scope
    - custom lifecycle created by implementing the Scope interface and registering it
    - use when: built-in scopes do not match your requirement
    - real world case: tenant scope in a multi-tenant SaaS app or a job scope for batch processing

```java
@Component
@Scope("prototype")
```

</details>

<details>
<summary><b>Exception Handling</b></summary>

1. Default Spring exception handling
   - Spring Boot gives default error response like `404`, `400`, `500`
   - use when: you do not need custom error body

2. `@ExceptionHandler` - method level
    - written on a method inside a controller and handles exceptions for that controller
    - use when: custom handling is needed only for one controller

3. `@ControllerAdvice` + `@ExceptionHandler` - application level
   - handles exceptions globally across all controllers
   - use when: you want common error response format for the whole application

<details>
<summary><b>Example</b></summary>

```java
@RestController
@RequestMapping("/users")
public class UserController {

    @GetMapping("/{id}")
    public String getUser(@PathVariable int id) {
        if (id <= 0) {
            throw new IllegalArgumentException("Invalid user id");
        }
        return "user-" + id;
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<String> handleIllegalArgument(IllegalArgumentException ex) {
        return ResponseEntity.badRequest().body(ex.getMessage());
    }
}
```

```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(Exception.class)
    public ResponseEntity<String> handleException(Exception ex) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body("Something went wrong: " + ex.getMessage());
    }
}
```

</details>

</details>

<details>
<summary><b>@Bean vs @Component</b></summary>

| Feature | `@Bean` | `@Component` |
|---|---|---|
| Applied on | Method inside `@Configuration` class | Class directly |
| Bean creation | Manual bean creation by returning object from method | Automatically detected by component scan |
| Use when | You need full control over object creation | Class is part of your application and should be auto-managed |
| Best for | Third-party classes, library classes, custom construction logic | Service, repository, controller, helper classes |
| Configuration style | Explicit / Java config based | Annotation scanning based |
| Custom logic | Easy to add custom initialization in method | Limited to what class constructor/config already does |

### Quick Rule

- Use `@Component` for your own application classes
- Use `@Bean` when you need to create the object manually or configure a third-party class

### Real World Examples

- `@Component` - `UserService`, `EmailValidator`, `PaymentHelper`
- `@Bean` - `ObjectMapper`, `RestTemplate`, third-party SDK client, custom `DataSource`

### Example

```java
@Configuration
public class AppConfig {

    @Bean
    public ObjectMapper objectMapper() {
        return new ObjectMapper();
    }
}

@Component
public class UserService {
}
```

</details>

<details>
<summary><b>@Inject vs @Autowired</b></summary>

| Feature | `@Inject` | `@Autowired` |
|---|---|---|
| Standard | Java standard (`javax.inject` / `jakarta.inject`) | Spring-specific |
| Source | JSR-330 | Spring Framework |
| Purpose | Dependency injection only | Dependency injection in Spring |
| Spring features | Limited | Supports Spring-specific options like `required = false` |
| Best use | When you want standard annotation style | When you want full Spring integration |

### Quick Rule

- Use `@Autowired` in Spring projects when you want Spring-specific behavior
- Use `@Inject` when you prefer a framework-neutral standard annotation

</details>

<details>
<summary><b>Internlisation</b></summary>

- Internationalization (i18n) means showing messages in different languages based on user locale.
- Spring uses the `MessageSource` interface for resolving messages.
- Messages are usually stored in property files like `messages.properties`, `messages_en.properties`, `messages_fr.properties`.
- You can configure `ResourceBundleMessageSource` as a bean.
- Messages are read using `getMessage()` from `MessageSource` or by autowiring `MessageSource`.

Typical flow:
1. Define messages in property files
2. Configure message source bean
3. Detect locale from request or default locale
4. Fetch the correct message using key + locale

<details>
<summary><b>Example</b></summary>

```properties
# messages.properties
welcome.message=Welcome User

# messages_fr.properties
welcome.message=Bienvenue Utilisateur
```

```java
@Configuration
public class MessageConfig {

    @Bean
    public MessageSource messageSource() {
        ResourceBundleMessageSource messageSource = new ResourceBundleMessageSource();
        messageSource.setBasename("messages");
        messageSource.setDefaultEncoding("UTF-8");
        return messageSource;
    }
}
```

```java
@RestController
public class MessageController {

    @Autowired
    private MessageSource messageSource;

    @GetMapping("/welcome")
    public String welcome(Locale locale) {
        return messageSource.getMessage("welcome.message", null, locale);
    }
}

Locale = en_US  -> messages_en.properties
Locale = fr_FR  -> messages_fr.properties
```

</details>
</details>


<details>
<summary><b>Bean Life Cycle</b></summary>

- Bean lifecycle means how Spring creates, initializes, uses, and destroys a bean.

### Lifecycle Flow

1. Spring container creates the bean object
2. Dependencies are injected
3. Aware interfaces are called if implemented
4. `@PostConstruct` or init method runs
5. Bean is ready to use
6. On container shutdown, `@PreDestroy` or destroy method runs

| Step | What happens | What you can do here | Common hook |
|---|---|---|---|
| 1 | Bean object is created | Keep constructor logic light, assign defaults | Constructor |
| 2 | Dependencies are injected | Use collaborators, validate injected values | Constructor/Setter injection |
| 3 | Spring gives container metadata | Access bean name, context, environment | `*Aware` interfaces |
| 4 | Initialization runs | Add startup logic, cache warmup, config validation | `@PostConstruct`, `afterPropertiesSet()` |
| 5 | Bean is ready | Run normal business logic | Service methods |
| 6 | Bean is destroyed | Cleanup resources, stop threads, close connections | `@PreDestroy`, `destroy()` |

<details>
<summary><b>Example</b></summary>

```java
@Component
public class PaymentService {

    @PostConstruct
    public void init() {
        System.out.println("Bean initialized");
    }

    @PreDestroy
    public void cleanup() {
        System.out.println("Bean destroyed");
    }
}
```

</details>

</details>

<details>
<summary><b>Expression Langugage</b></summary>

- Spring Expression Language (SpEL) is used to evaluate expressions at runtime.
- It can read properties, call methods, access bean values, and compute expressions.

### Two Common Usages

1. Property Injection with `@Value`
    - inject value from `application.properties` or `application.yml`
    - use when: you want simple config values like port, app name, timeout

2. SpEL Expression Evaluation
    - evaluate expressions like method call, string operation, bean property access
    - use when: value depends on computation or another bean/property

### How It Works

- `${...}` -> reads external property value
- `#{...}` -> evaluates Spring expression

### Quick Rule

- use `${...}` for normal configuration values
- use `#{...}` when you need dynamic calculation or bean-based expression

### Example

```properties
app.name=OrderService
app.tax=18
```

```java
@Component
public class InvoiceService {

     @Value("${app.name}")
     private String appName;

     @Value("#{${app.tax} * 2}")
     private int doubleTax;
}
```

### Interview Points

- `@Value` is best for small number of config values
- For many related properties, prefer `@ConfigurationProperties`
- SpEL is powerful, but do not overuse it for simple configuration

</details>

<details>
<summary><b>Applicaion Context</b></summary>


- **Auto-configuration** - Spring Boot automatically configures beans based on the dependencies present in the classpath
- **Starter dependencies** - pre-packaged dependency groups like `spring-boot-starter-web` reduce manual dependency management
- **Embedded server** - runs with embedded Tomcat, Jetty, or Undertow so you can start the app directly
- **Convention over configuration** - follows default setup so you write less boilerplate configuration

</details>

<details>
<summary><b>Common Features</b></summary>

- **Externalized configuration** - use `application.properties` or `application.yml`
- **Profiles** - separate config for `dev`, `test`, and `prod`
- **Actuator** - production-ready monitoring endpoints
- **Spring Boot DevTools** - auto-restart and developer convenience features

</details>

<details>
<summary><b>Typical Flow</b></summary>

1. Add starter dependency
2. Create main class with `@SpringBootApplication`
3. Write controllers, services, and repositories
4. Run application with embedded server

</details>

<details>
<summary><b>Main Annotation</b></summary>

`@SpringBootApplication` is a shortcut for:

- `@Configuration`
- `@EnableAutoConfiguration`
- `@ComponentScan`

</details>

<details>
<summary><b>Why Spring Boot</b></summary>

- Faster project setup
- Less XML and boilerplate configuration
- Easy production deployment
- Better integration with modern microservices development

</details>