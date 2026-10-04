---
title: "Hash Tables"
date: 2026-10-04 21:27:02 +05:30
categories: [Data Structures, Hash Tables]
tags: []
---

## Valid Sudoku

```python
class Solution:
    def isValidSudoku(self, board: list[list[str]]) -> bool:
        rows = defaultdict(set)
        cols = defaultdict(set)
        box = defaultdict(set)

        for r in range(9):
            for c in range(9):
                cell = board[r][c]
                if cell == '.':
                    continue
                if (cell in rows[r]) or (cell in cols[c]) or (cell in box[(r//3,c//3)]):
                    return False
                rows[r].add(cell)
                cols[c].add(cell)
                # box - (0, 1) (1, 0)....
                box[(r//3,c//3)].add(cell)
        return True
```

## Longest Consecutive Sequence

```python
class Solution:
    def longestConsecutive(self, nums: list[int]) -> int:

        seen = set(nums)
        maxi = 0
        for si in seen:
            if si-1 not in seen:
                size = 1
                while si+size in seen:
                    size += 1
                maxi = max(maxi, size)
        return maxi
```
