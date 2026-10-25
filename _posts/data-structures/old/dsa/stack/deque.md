# Deque

## When to Use
- Sliding window maximum/minimum
- BFS with 0-1 weights
- Monotonic deque problems
- Clue words: "sliding window max", "double-ended", "window"

## Templates

### Sliding Window Maximum
```java
Deque<Integer> deque = new ArrayDeque<>(); // stores indices
int[] result = new int[nums.length - k + 1];
for (int i = 0; i < nums.length; i++) {
    // Remove elements outside window
    while (!deque.isEmpty() && deque.peekFirst() < i - k + 1) {
        deque.pollFirst();
    }
    // Remove smaller elements (they'll never be max)
    while (!deque.isEmpty() && nums[deque.peekLast()] < nums[i]) {
        deque.pollLast();
    }
    deque.offerLast(i);
    if (i >= k - 1) {
        result[i - k + 1] = nums[deque.peekFirst()];
    }
}
return result;
```

### 0-1 BFS (Shortest Path with 0/1 weights)
```java
int[] dist = new int[n];
Arrays.fill(dist, Integer.MAX_VALUE);
dist[start] = 0;
Deque<Integer> deque = new ArrayDeque<>();
deque.offerFirst(start);
while (!deque.isEmpty()) {
    int u = deque.pollFirst();
    for (int[] edge : graph.get(u)) { // {neighbor, weight 0 or 1}
        int v = edge[0], w = edge[1];
        if (dist[u] + w < dist[v]) {
            dist[v] = dist[u] + w;
            if (w == 0) deque.offerFirst(v);
            else deque.offerLast(v);
        }
    }
}
```

## Key Concepts
- **ArrayDeque** in Java: faster than LinkedList for stack/queue
- Monotonic deque keeps elements in sorted order (ascending or descending)
- Front = max/min of current window

## Key Problems
| Problem | Approach |
|---------|----------|
| Sliding Window Maximum | Monotonic decreasing deque |
| Sliding Window Minimum | Monotonic increasing deque |
| Shortest Path with 0-1 weights | 0-1 BFS with deque |
| Max Value of Equation | Monotonic deque + sliding window |
