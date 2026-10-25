# Common System Design Problems

## Template for Any System Design Interview

```
1. Requirements (5 min)
   → Functional: what should the system DO?
   → Non-functional: scale, latency, availability
   → Constraints: read-heavy? write-heavy? data size?

2. Estimation (5 min)
   → DAU, QPS, storage, bandwidth

3. High-Level Design (10 min)
   → Draw boxes: Client → LB → App → Cache → DB
   → Identify core APIs

4. Deep Dive (15 min)
   → Database schema
   → Scaling bottlenecks
   → Specific algorithms

5. Wrap Up (5 min)
   → Trade-offs made
   → What you'd improve
```

## Quick Reference

### URL Shortener
- **Core:** Base62 encode auto-increment ID or hash
- **Storage:** Key-value store (shortURL → longURL)
- **Scale:** Cache hot URLs, read-heavy (100:1)
- **Extras:** Analytics, expiry, custom aliases

### Rate Limiter
- **Algorithms:** Token Bucket, Sliding Window, Fixed Window
- **Where:** API Gateway or middleware
- **Storage:** Redis (userId → count + timestamp)

### Chat System (WhatsApp/Messenger)
- **Protocol:** WebSocket for real-time
- **Storage:** Message queue (Kafka) + NoSQL (Cassandra)
- **Key decisions:** Push vs Pull, group chat fan-out

### Notification System
- **Types:** Push, SMS, Email
- **Architecture:** Producer → Message Queue → Workers → 3rd Party APIs
- **Key:** Retry with exponential backoff, dedup by messageId

### News Feed (Twitter/Instagram)
- **Fan-out on write:** Pre-compute feed when user posts (fast read)
- **Fan-out on read:** Compute feed at read time (fast write)
- **Hybrid:** Fan-out on write for normal users, on read for celebrities

### Distributed Cache (Redis)
- **Consistent Hashing** for key distribution
- **Replication** for availability
- **Eviction:** LRU

## My Notes
<!-- Add your own observations, mistakes, and learnings below -->
