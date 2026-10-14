---
title: "Dynamic Programming Skelton"
date: 2026-10-14 13:51:38 +05:30
categories: [Data Structures, Dynamic Programming]
tags: []
---



## Core Idea

Dynamic programming converts recursive choices into dynamic loops.

```text
f(x) -> define the function that solves the smallest problem
```

---

## Intuition

Given an array:

```python
arr = [1, 2, 3, 4, 5, 6]
```

To generate all possible subarrays starting at every index:

```python
for i in range(0, n):
    for j in range(i + 1, n):
        for k in range(j + 1, n):
            ...
```

This can lead to `n` nested loops.

A recursive form can express the same repeated structure:

```python
def f(i):
    if i == n:
        return

    for j in range(i, n):
        f(j + 1)
```

---

## Pattern 1: Pick or Skip

This is a decision-based pattern. At each index, either pick the current element or skip it.

```python
def f(i, temp):
    if i == n:
        ans.append(temp.copy())
        return

    # Pick
    temp.append(a[i])
    f(i + 1, temp)
    temp.pop()

    # Skip
    f(i + 1, temp)
```

### Example: Count Palindromic Substrings

```python
class Solution:
    def countSubstrings(self, s: str) -> int:
        count = 0
        n = len(s)

        dp = [[False] * n for _ in range(n)]

        for i in range(n - 1, -1, -1):
            for j in range(i, n):
                if s[i] == s[j] and (j - i <= 2 or dp[i + 1][j - 1]):
                    dp[i][j] = True
                    count += 1

        return count
```

---

## Pattern 2: String Formation or Combination

Try every possible segment beginning at the current index, then recursively continue from the next index.

```python
def f(i):
    if i == n:
        return

    for j in range(i, n):
        current = a[i:j + 1]
        f(j + 1)
```

### Combination Tree

```text
combination([], 0)
├── choose first option
│   └── combination([...], 1)
└── choose next option
    └── combination([...], 2)
```

---

## Pattern 3: Permutation

Use a `visited` array to track which elements are currently selected.

```python
visited = [0, 0, 0, 0]


def f(i):
    if i == n:
        return

    if visited[i] == 0:
        visited[i] = 1
        f(i + 1)
        visited[i] = 0
```

---

## Types of Dynamic Programming

1. **Top-down**: Divide the problem into smaller subproblems.
2. **Bottom-up**: Start from the known cases.
3. **Space optimized**: Retain only the previous states needed to calculate the next state.

---

## Common Dynamic Programming Problems

1. Knapsack
2. Unbounded Knapsack
3. Minimum Among All
4. Count Number of Ways

---

## Finding the Base Case

Ask:

> What are the smallest subproblems I can solve directly?

Everything else follows from those direct answers.

Finding the correct base cases is the main thinking task.

### Finding Direct Answers

Ask:

> For which inputs do I already know the answer without recursion?

The answer depends on:

- Problem understanding
- Pattern recognition

---

## Quick Mental Checklist

When writing recursion:

1. Define the recurrence.
2. Ask: what is the smallest meaningful input?
3. Write direct answers for those inputs.
4. Guarding is handled automatically once the boundaries and base cases are correct.

---

## Simple Analogy

Think of dynamic programming like building stairs:

1. **Substructure**: How the steps connect.
2. **Base case**: Where the ground starts.
3. **Guarding**: Do not dig below the ground.

