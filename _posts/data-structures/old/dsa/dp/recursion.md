# Recursion

## Technique
- <u>**Problem has a recursive structure (smaller subproblems)**</u>
- Tree/graph traversal
- Generate all combinations/permutations
- Divide and conquer

## Template

### Basic Recursion
```python
def solve(n):
    if n <= 1: return n  # base case
    return solve(n - 1) + solve(n - 2)  # recursive case
```

### Divide and Conquer
```python
def solve(arr, lo, hi):
    if lo == hi: return arr[lo]  # base
    mid = lo + (hi - lo) // 2
    left = solve(arr, lo, mid)
    right = solve(arr, mid + 1, hi)
    return merge(left, right)
```

## Key Concepts
- **Base case**: Smallest subproblem with known answer
- **Recursive case**: Break into smaller subproblems
- **Call stack**: Each call adds a frame; too deep → StackOverflow
- **Tail recursion**: Recursive call is last operation (JVM doesn't optimize this)
- **Time complexity**: Use recurrence relations (Master Theorem)

## Key Problems
| Problem | Approach |
|---------|----------|
| Fibonacci | Base: f(0)=0, f(1)=1, recurse |
| Power(x, n) | Divide: x^n = x^(n/2) * x^(n/2) |
| Merge Sort | Divide, sort halves, merge |
| Tower of Hanoi | Move n-1 to aux, move 1, move n-1 to target |
| Generate Parentheses | Track open/close count |
