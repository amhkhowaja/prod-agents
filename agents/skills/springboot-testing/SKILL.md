---
name: springboot-testing
description: Testing strategy for production Spring Boot services — JUnit 5 unit tests, slice tests (@WebMvcTest, @DataJpaTest), realistic integration tests with Testcontainers, contract testing (Spring Cloud Contract), and concurrency tests. Use when adding tests or setting up a test strategy for a Spring Boot service.
---

# Spring Boot Testing

## Test pyramid
1. **Unit** (fast, most numerous): pure logic with JUnit 5 + Mockito, no Spring context.
2. **Slice**: `@WebMvcTest` (controllers + MockMvc), `@DataJpaTest` (repositories),
   `@JsonTest` (serialization) — load only the relevant slice.
3. **Integration**: full context with **Testcontainers** (real Postgres/Kafka/Redis).
4. **Contract**: producer/consumer compatibility with the API Architect's contract.

## Testcontainers (realistic integration)
```java
@SpringBootTest
@Testcontainers
class OrderIT {
  @Container
  static PostgreSQLContainer<?> pg = new PostgreSQLContainer<>("postgres:16");

  @DynamicPropertySource
  static void props(DynamicPropertyRegistry r) {
    r.add("spring.datasource.url", pg::getJdbcUrl);
    r.add("spring.datasource.username", pg::getUsername);
    r.add("spring.datasource.password", pg::getPassword);
  }
}
```
Prefer Testcontainers over H2 — test against the real engine you run in production.
Spring Boot 3.1+ supports `@ServiceConnection` to auto-wire container connection details.

## Slice example
```java
@WebMvcTest(OrderController.class)
class OrderControllerTest {
  @Autowired MockMvc mvc;
  @MockBean OrderService service;

  @Test void returns404WhenMissing() throws Exception {
    when(service.find("x")).thenThrow(new NotFoundException());
    mvc.perform(get("/orders/x")).andExpect(status().isNotFound());
  }
}
```

## Contract testing
Spring Cloud Contract (or Pact): define the contract, generate producer verification
tests and consumer stubs, run in CI so producer and consumers can't drift.

## Concurrency tests
For race-prone paths, fire N concurrent operations and assert invariants:
```java
int n = 50;
var latch = new CountDownLatch(n);
var pool = Executors.newFixedThreadPool(n);
IntStream.range(0, n).forEach(i -> pool.submit(() -> { service.debit(id, ONE); latch.countDown(); }));
latch.await();
assertThat(repo.findById(id).balance()).isEqualByComparingTo(expected); // no lost updates
```

## Gates
- JaCoCo coverage thresholds in the build; fail CI below target.
- Run `./gradlew build` / `mvn verify` — tests must pass before "done".
- Mutation testing (PIT) on critical modules where coverage quality matters.
