---
title: "Back of Envelope"
date: 2026-10-15 12:57:50 +05:30
categories: [BLOG]
tags: []
published: false
---

1. Users?
2. Actions per user?
3. Daily operations?
4. Average QPS?
5. Peak QPS?
6. Record size?
7. Daily + 5 year storage?
8. Replication factor?
9. Bandwidth?
10. Concurrent connections?

## 1. Traffic Estimation

1. Daily Operations

```text
Daily Ops = Users × Actions per User per Day

500M users × 40 msgs/day
= 20B msgs/day

```

1. Average QPS

```text
QPS = Daily Ops / 10^5
20*10^9/10^5 = 20*10^4 = 20K QPS
```

1. Peak QPS (Use 5x to 10x multiplier.)

```text
Peak QPS = Average QPS × 5
= 20K QPS * 5 = 100K QPS
```
