---
name: springboot-concurrency
description: Concurrency correctness in Spring Boot — stateless singletons, thread-pool sizing, @Async executors, virtual threads (Java 21), transaction boundaries and isolation, optimistic vs pessimistic locking, and closing read-modify-write races. Use when a service has shared state, background tasks, or concurrent writes to the same data.
---

# Spring Boot Concurrency

## Bean thread-safety
Spring beans are **singletons by default** and shared across request threads. Keep them
**stateless** — no mutable instance fields holding request/user state. Store per-request
state in method locals, `@RequestScope` beans, or explicit parameters.

## Executors and @Async
Define explicit, bounded executors; never rely on the default unbounded one.
```java
@Bean("appTaskExecutor")
ThreadPoolTaskExecutor taskExecutor() {
    var ex = new ThreadPoolTaskExecutor();
    ex.setCorePoolSize(8);
    ex.setMaxPoolSize(16);
    ex.setQueueCapacity(500);
    ex.setThreadNamePrefix("app-async-");
    ex.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy());
    return ex;
}

@Async("appTaskExecutor")
CompletableFuture<Result> process(Cmd cmd) { ... }
```
Isolate pools per workload (bulkheading) so one slow task type can't starve others.

## Virtual threads (Java 21+)
For high-concurrency **blocking I/O** workloads:
```yaml
spring.threads.virtual.enabled: true
```
Great for many concurrent blocking calls; not a substitute for fixing genuinely
CPU-bound contention. Avoid pinning: don't hold `synchronized` across blocking I/O
(use `ReentrantLock` instead).

## Transactions
```java
@Transactional                       // default: REQUIRED, read-write
public void placeOrder(...) { ... }

@Transactional(readOnly = true)      // read paths
public OrderView get(...) { ... }
```
- Keep transactions short; don't call remote services inside a DB transaction.
- Understand propagation (REQUIRED vs REQUIRES_NEW) and self-invocation caveat
  (proxy-based `@Transactional` doesn't apply to internal method calls).

## Locking — closing read-modify-write races
**Optimistic (preferred, high concurrency, low conflict):**
```java
@Entity
class Account {
  @Version long version;   // JPA throws OptimisticLockException on conflict → retry
}
```
**Pessimistic (high conflict, must not lose):**
```java
@Lock(LockModeType.PESSIMISTIC_WRITE)
@Query("select a from Account a where a.id = :id")
Account findForUpdate(@Param("id") Long id);
```
For counters/balances, prefer atomic DB updates over read-then-write:
```java
@Modifying
@Query("update Account a set a.balance = a.balance - :amt where a.id = :id and a.balance >= :amt")
int debit(@Param("id") Long id, @Param("amt") BigDecimal amt);   // check rows affected
```

## Idempotency
For retried/at-least-once operations, use an idempotency key + a uniqueness constraint
so duplicate deliveries are safely no-ops.

## Testing concurrency
Exercise race-prone paths with concurrent threads (e.g. `CompletableFuture.allOf` over
N parallel calls) and assert invariants (no lost updates, correct final state).
