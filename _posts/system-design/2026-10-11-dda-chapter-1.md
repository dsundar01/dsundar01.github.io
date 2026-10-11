---
title: "DDA Chapter 1"
date: 2026-10-11 20:13:52 +05:30
categories: [System Design, DDA]
tags: []
published: false

---

## Chapter 1

- <https://danlebrero.com/2021/09/01/designing-data-intensive-applications-summary/>
- <https://github.com/ahmedhammad97/Designing-Data-Intensive-Applications-Notes/blob/main/README.md>
- <https://github.com/abdullah-jaffer/Designing-Data-Intensive-Applications-Chapter-by-Chapter-Summary/blob/main/1.Foundations%20of%20Data%20Systems/Chapter1.md>
- <https://avenuej.dev/educational-resources/system-design/>
- <https://web.goodnotes.com/s/lBJGCtfBvoO9dNkFDgLzSJ#page-2>
- <https://web.goodnotes.com/s/slEB4Oy8wWrp6S43Egyini#page-2>
Reliability

As computing demand grows, systems run on hundreds or thousands of machines. At that scale, machine failures become normal rather than rare. Hardware redundancy can protect individual components, but it cannot prevent the loss of entire machines. Therefore modern distributed systems rely on software fault tolerance, replication, and automatic recovery mechanisms to continue operating despite machine failures.

As computing demand grows, you need more and more machines. Once you have thousands of machines, failures become routine, so software-level replication and recovery become more valuable than trying to make every individual machine perfect.

---

Yes, that's a good takeaway. I'd refine it slightly:

Takeaway

Tail latencies (p95/p99/p99.9) are important because they tell you how bad the slowest requests are.

p95 = 95% of requests finished before this time.
p99 = 99% of requests finished before this time.
They expose the "slow tail" that averages hide.

In a fan-out architecture, the user waits for the slowest dependency.

Overall latency ≈ max(service latencies)
Not average(service latencies)
Frontend
   |
   +--> Service A = 50ms
   +--> Service B = 70ms
   +--> Service C = 500ms

User sees ≈ 500ms

because:

max(50, 70, 500) = 500

not:

average(50, 70, 500) = 206ms

Therefore, as fan-out increases:
Average latency becomes less useful.
p95/p99/p99.9 become more important.
One slow dependency can make the entire user request slow.
Interview-style one-liner

In fan-out systems, end-to-end latency is determined by the slowest downstream service (max latency), so tail latencies (p95/p99/p99.9) are more important than averages because they better reflect actual user experience.

---

Head-of-Line (HOL) Blocking means:

A fast request gets stuck waiting behind a slow request that is ahead of it in a queue.

Think of a supermarket checkout:

Customer 1 -> 100 items  (slow)
Customer 2 -> 1 item     (fast)
Customer 3 -> 2 items    (fast)

Even though Customer 2 and 3 could be processed quickly, they must wait for Customer 1.

Slow request
     ↓
[Req1][Req2][Req3]
 100ms  5ms   5ms

Req2 waits
Req3 waits

Server Example

Suppose a server has only one worker thread.

Requests arrive:

Req1 -> Database query -> 5 sec
Req2 -> Read from cache -> 5 ms
Req3 -> Read from cache -> 5 ms

Queue:

Req1
Req2
Req3

The server processes sequentially:

Req1 -> 5 sec
Req2 -> 5 ms
Req3 -> 5 ms

Although Req2 itself needs only 5 ms, the user waits:

5000 ms + 5 ms

This is head-of-line blocking.

Why DDIA mentions client-side latency

Server metrics may show:

Req2 processing time = 5 ms

But the client observed:

Wait in queue = 5000 ms
Processing = 5 ms

Total = 5005 ms

That's why DDIA says:

Measure latency from the client side.

The server might only measure processing time, while the user experiences:

Queue wait

- Network
- Processing
- Retries
- Everything else

Relation to Tail Latency

Head-of-line blocking is one reason for high tail latency.

Example:

1000 requests
999 complete in 10 ms
1 request takes 5 sec

That one slow request may cause many requests behind it to wait.

Result:

More p99 / p99.9 latency

even though most requests are inherently fast.

One-line interview answer

Head-of-line blocking occurs when a slow request at the front of a queue delays subsequent requests, causing otherwise fast requests to experience high latency. This is a common source of tail latency in distributed systems

---

## Chapter 2

- why nosql
- tranlation layer
- one to many solved by nosql
- relational better at many to one and many to many
- graph : better at many to many
- nosql : schema on read
- query languages
  - SQL
  - map reduce
  - graph's cyper

----
why nosql
translation layer
compare sql and nosql

- application code simplicity
- schema flexiblity
- data locality for queries
query lanugages
- declatiave and imperative
- map reduce querying
graph data model
- graph vs n/w mode
