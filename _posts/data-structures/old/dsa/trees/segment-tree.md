# Segment Tree

## When to Use
- Range queries with updates (sum, min, max)
- O(log n) per query and update
- Clue words: "range sum query", "range minimum", "update and query"

## Template

### Build, Update, Query
```java
int[] tree;
int n;

void build(int[] nums) {
    n = nums.length;
    tree = new int[4 * n];
    build(nums, 1, 0, n - 1);
}

void build(int[] nums, int node, int start, int end) {
    if (start == end) {
        tree[node] = nums[start];
    } else {
        int mid = (start + end) / 2;
        build(nums, 2 * node, start, mid);
        build(nums, 2 * node + 1, mid + 1, end);
        tree[node] = tree[2 * node] + tree[2 * node + 1]; // sum
    }
}

void update(int node, int start, int end, int idx, int val) {
    if (start == end) {
        tree[node] = val;
    } else {
        int mid = (start + end) / 2;
        if (idx <= mid) update(2 * node, start, mid, idx, val);
        else update(2 * node + 1, mid + 1, end, idx, val);
        tree[node] = tree[2 * node] + tree[2 * node + 1];
    }
}

int query(int node, int start, int end, int l, int r) {
    if (r < start || end < l) return 0; // out of range
    if (l <= start && end <= r) return tree[node]; // fully in range
    int mid = (start + end) / 2;
    return query(2 * node, start, mid, l, r) + query(2 * node + 1, mid + 1, end, l, r);
}
```

### Lazy Propagation (Range Update)
```java
int[] lazy;

void pushDown(int node) {
    if (lazy[node] != 0) {
        tree[2 * node] += lazy[node];
        tree[2 * node + 1] += lazy[node];
        lazy[2 * node] += lazy[node];
        lazy[2 * node + 1] += lazy[node];
        lazy[node] = 0;
    }
}

void rangeUpdate(int node, int start, int end, int l, int r, int val) {
    if (r < start || end < l) return;
    if (l <= start && end <= r) {
        tree[node] += val;
        lazy[node] += val;
        return;
    }
    pushDown(node);
    int mid = (start + end) / 2;
    rangeUpdate(2 * node, start, mid, l, r, val);
    rangeUpdate(2 * node + 1, mid + 1, end, l, r, val);
    tree[node] = tree[2 * node] + tree[2 * node + 1];
}
```

## Key Problems
| Problem | Approach |
|---------|----------|
| Range Sum Query - Mutable | Basic segment tree |
| Count of Smaller Numbers After Self | Segment tree on values |
| Range Minimum Query | Segment tree with min |
