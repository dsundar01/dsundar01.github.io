---
title: "Sliding Window"
date: 2026-10-13 16:49:58 +05:30
categories: [Data Structures, Sliding Window]
tags: [sliding-window, two-pointers, arrays, strings]
---

# Sliding Window

The Sliding Window pattern is an optimization technique for solving problems involving **contiguous subarrays or substrings**.

The key observation is that **consecutive windows overlap significantly**. Instead of recomputing everything for every window, we only account for:

- Elements entering the window
- Elements leaving the window

This often reduces a brute-force solution from **O(n²)** to **O(n)**.

---

## Core Idea

Consider a window of size `k`.

```
[1, 2, 3, 4]
 ^-----^

Next window:

[1, 2, 3, 4]
    ^-----^
```

Both windows share `k - 1` elements.

Instead of recalculating the entire window:

- Remove the contribution of the outgoing element
- Add the contribution of the incoming element

---

## Expand and Shrink Mental Model

Most variable-size sliding window problems follow this pattern:

1. Expand the window by moving `right`.
2. Continue until a condition becomes invalid.
3. Shrink the window by moving `left`.
4. Restore the condition.
5. Repeat.

```
Expand → Condition breaks → Shrink → Condition restored
```

---

## Why Sliding Window Works

Sliding Window works best when the window condition changes in a **consistent direction (monotonic behavior)** as the window grows or shrinks.

### Typical Characteristics

- Growing the window makes the condition harder or easier to satisfy consistently.
- Shrinking the window can restore the condition.
- The validity of the window can be determined from its current state.

Examples:

✅ Sum ≤ K  
✅ At most K distinct characters  
✅ No duplicate characters  
✅ Frequency-based constraints

---

## When to Use Sliding Window

Sliding Window is usually applicable for:

- Subarrays
- Substrings
- Longest valid window
- Shortest valid window
- Maximum window
- Minimum window
- Count of valid windows

Common interview phrases:

- Longest substring...
- Smallest subarray...
- Maximum consecutive...
- Minimum window...
- At most K...
- Exactly K...

---

## When Not to Use Sliding Window

Avoid Sliding Window when:

- Elements are **not contiguous**
- There is **no monotonic property**
- Elements can be rearranged
- You must process **all possible subarrays independently**
- The condition does not improve predictably when shrinking

Examples:

- Non-contiguous subsequence problems
- Arbitrary rearrangement problems
- Many problems involving negative numbers where window expansion/shrinking is not monotonic

---

# Generic Template

```python
left = right = 0

while right < n:

    while window_is_invalid:
        left += 1

    right += 1
```

---

# Longest / Maximum Window Pattern

Use when looking for:

- Longest substring
- Maximum length subarray
- Largest valid window

```python
while condition_violated:
    shrink()

result = max(result, right - left + 1)
```

### Idea

Maintain the largest valid window seen so far.

---

# Minimum Window Pattern

Use when looking for:

- Smallest window
- Shortest subarray
- Minimum substring

```python
while condition_satisfied:
    result = min(result, right - left + 1)
    shrink()
```

### Why?

Once a valid window is found, any larger version is unnecessary. We immediately try to make it smaller.

---

# Exactly K Pattern

A powerful trick:

```text
Exactly(K) = AtMost(K) - AtMost(K - 1)
```

Used frequently for:

- Exactly K distinct characters
- Exactly K odd numbers
- Exactly K occurrences

Example:

```text
Subarrays with Exactly 3 Distinct
=
AtMost(3) - AtMost(2)
```

---

# Choosing the Window State

The expand/shrink logic is often identical across problems.

What changes is **how we represent the state of the current window**.

| Requirement                 | Data Structure    |
| --------------------------- | ----------------- |
| Sum / Average               | Running Sum       |
| Product                     | Running Product   |
| Frequency Count             | HashMap / Counter |
| Character Frequency         | Counter / int[26] |
| Duplicate Detection         | HashSet           |
| Track Indices               | HashMap           |
| Maintain Order              | Deque             |
| Maximum / Minimum in Window | Monotonic Queue   |
| Median in Window            | Two Heaps         |
| Binary Problems             | Bit Manipulation  |

---

## Monotonic Queue vs Heap

For window maximum/minimum problems:

### Heap

- Can find max/min efficiently
- Does not naturally know when elements leave the window
- Requires lazy deletion

### Monotonic Queue

- Maintains candidates in sorted order
- Removes expired elements naturally
- Ideal for sliding window max/min problems

**Rule of thumb:**  
For sliding-window maximum/minimum, a Monotonic Queue is usually the preferred solution.

---

# Important Formulas

## Count of Valid Subarrays

```python
count += (right - left + 1)
```

### Why?

For a valid window:

```text
[left ... right]
```

Every starting index between:

```text
left, left+1, ..., right
```

can form a valid subarray ending at `right`.

Therefore:

```text
Number of new valid subarrays
=
(right - left + 1)
```

---

## Total Number of Subarrays

For an array of size `n`:

```text
n * (n + 1) / 2
```

Example:

```text
n = 4

[1]
[2]
[3]
[4]

[1,2]
[2,3]
[3,4]

[1,2,3]
[2,3,4]

[1,2,3,4]

Total = 10
```

Formula:

```text
4 × 5 / 2 = 10
```

---

# Quick Takeaways

1. Consecutive windows overlap heavily. Recompute only what changes.
2. Sliding Window works best when the condition behaves monotonically.
3. Think in terms of **Expand → Validate → Shrink**.
4. Most problems differ only in the **window state representation**.
5. For **longest** problems, update answer after restoring validity.
6. For **minimum** problems, update answer before shrinking further.
7. Remember:

```text
Exactly(K) = AtMost(K) - AtMost(K-1)
```

1. Counting trick:

```text
count += (right - left + 1)
```

1. For window max/min problems, think **Monotonic Queue** before Heap.

---

## One-Line Summary

> Sliding Window is a technique for processing contiguous ranges efficiently by reusing work between overlapping windows and maintaining only the state affected by incoming and outgoing elements.
