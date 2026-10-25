---
title: "Foundations"
date: 2026-10-17 15:22:33 +05:30
categories: [System Design, Distributed Systems]
tags: []
published: false
---

1Foundations

1.1
Logical Clocks & Causality Tracking

Why Physical Clocks Fail
Lamport Timestamps
When Lamport Timestamps Are Enough
Vector Clocks: Detecting Concurrency
Why Vector Clocks Do Not Scale
Interval Tree Clocks
Version Vectors: The Practical Alternative
Dotted Version Vectors
Hybrid Logical Clocks
Google Spanner's TrueTime
Choosing the Right Clock
Architecture Diagram
Key Points
Common Mistakes

1.2
Vector Clocks & Version Vectors

Why Lamport Clocks Are Not Enough
How Vector Clocks Work
Comparing Vector Clocks: The Key Operation
The Original Dynamo Story
A Worked Sibling Merge
The Size Problem
Dotted Version Vectors: Riak's Innovation
Vector Clocks vs. Version Vectors
Interval Tree Clocks: Beyond Fixed Node Sets
Hybrid Logical Clocks: A Different Tool
When Vector Clocks Are the Right Choice
When to Use Something Else
Architecture Diagram
Key Points
Common Mistakes

1.3
Hybrid Logical Clocks (HLC)

The Gap Between Physical and Logical Clocks
The HLC Algorithm
Why This Works
Keeping HLC Honest: Skew Limits, Counter Bounds, and Restarts
CockroachDB: HLC in Production
YugabyteDB: Safe Time
HLC vs. Other Clock Approaches
NTP Considerations
Architecture Diagram
Key Points
Common Mistakes

<https://medium.com/@armironenko/distributed-systems-logical-time-explained-5f97949f180f>
<https://hosseinnejati.medium.com/time-and-clocks-in-distributed-systems-physical-vs-logical-clocks-13f702c9857a>

1.4
Consistency Models, CAP & PACELC

Four Useful Guarantees
Linearizability by Example
CAP Without the Slogan
PACELC in One Sentence
A Practical Decision Method
Architecture Diagram
Key Points
Common Mistakes

1.5
RPC, Retries & Idempotency

The Lost-Response Problem
A Safe Retry Shape
Retry Policy
Delivery Semantics
Design Checklist
Architecture Diagram
Key Points
Common Mistakes
