# Fenwick Tree (Binary Indexed Tree)

## When to Use
- Prefix sum queries with point updates
- Simpler alternative to Segment Tree (when range update not needed)
- O(log n) per query and update

## Template

```java
class FenwickTree {
    int[] tree;
    int n;

    FenwickTree(int n) {
        this.n = n;
        tree = new int[n + 1];
    }

    // Add val to index i (1-indexed)
    void update(int i, int val) {
        for (; i <= n; i += i & (-i))
            tree[i] += val;
    }

    // Prefix sum [1..i]
    int query(int i) {
        int sum = 0;
        for (; i > 0; i -= i & (-i))
            sum += tree[i];
        return sum;
    }

    // Range sum [l..r]
    int rangeQuery(int l, int r) {
        return query(r) - query(l - 1);
    }
}
```

## How It Works
- `i & (-i)` extracts the lowest set bit
- **Update**: walk up the tree adding to responsible nodes
- **Query**: walk down accumulating prefix sums
- Tree size: n + 1 (1-indexed)

## Build from Array
```java
FenwickTree ft = new FenwickTree(nums.length);
for (int i = 0; i < nums.length; i++) {
    ft.update(i + 1, nums[i]); // 1-indexed
}
```

## Key Problems
| Problem | Approach |
|---------|----------|
| Range Sum Query - Mutable | BIT for prefix sums |
| Count of Smaller Numbers After Self | BIT on value range |
| Count Inversions | BIT from right to left |
