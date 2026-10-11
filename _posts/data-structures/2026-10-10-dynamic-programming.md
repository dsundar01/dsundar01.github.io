---
title: "Dynamic Programming"
date: 2026-10-10 17:28:30 +05:30
categories: [Data Structures, Dynaminc Programming]
tags: [neetcode]
---

## 152. Maximum Product Subarray

```python
class Solution:
    def maxProduct(self, nums: list[int]) -> int:
        # max product can also come from 2 -ves
        # concept : fresh or reuse
        maxi = mini = cur = ans = nums[0]
        for i in range(1, len(nums)):
            cur = nums[i]
            oldmaxi = maxi
            # start fresh or conitnue with old
            maxi = max(cur, oldmaxi*cur, mini*cur)
            mini = min(cur, oldmaxi*cur, mini*cur)
            ans = max(ans, maxi)
        return ans
```

## 91. Decode Ways

```python
from functools import cache

class Solution:
    def numDecodings(self, s: str) -> int:
        N = len(s)

        @cache
        def f(i):
            if i == N:
                return 1  # Successfully decoded a valid path
            
            count = 0
            # Check chunks of length 1 or 2 (use min, not max)
            for j in range(i, min(i + 2, N)):
                curs = s[i:j+1]
                
                # Leading zeros are invalid (e.g., "0" or "06")
                if curs.startswith('0'):
                    break 
                    
                if 1 <= int(curs) <= 26:
                    count += f(j + 1)
                    
            return count

        return f(0)
```

## 647. Palindromic Substrings

```python
class Solution:
    def countSubstrings(self, s: str) -> int:
        N = len(s)
        dp = [[False] * N for _ in range(N)]
        count = 0
        for i in range(N-1, -1, -1):
            for j in range(i, N):
                if s[i] == s[j]:
                    leng =j-i+1
                    if leng <= 2 or dp[i+1][j-1]:
                        count += 1
                        dp[i][j] = True
        return count
```

## 97. Interleaving String

```python
class Solution:
    def isInterleave(self, s1: str, s2: str, s3: str) -> bool:
        m, n, o = len(s1), len(s2), len(s3)

        @cache
        def f(i, j, k):
            if k == o:
                return i == m and j == n #all char should be used
            op1 = op2 = False
            if i < m and s1[i] == s3[k]:
                op1 = f(i+1, j, k+1)
            if j < n and s2[j] == s3[k]:
                op2 = f(i, j+1, k+1)
            return op1 or op2
        return f(0, 0, 0)
```

## 72. Edit Distance

```python
class Solution:
    def minDistance(self, word1: str, word2: str) -> int:
        m, n = len(word1), len(word2)

        @cache
        def f(i, j):

            if i == m:
                return n-j
            if j == n:
                # insert all char
                return m-i #word2 ended but word2 exits

            if word1[i] == word2[j]:
                return f(i+1, j+1)
            else:
                insert = f(i, j+1) #j matched with new i, old i still need to be matched
                delete = f(i+1,j) #j need to matched yet
                repalce = f(i+1,j+1) #current i replaced
                return 1 + min(insert, delete, repalce)

        return f(0, 0)
```

## 312. Burst Balloons

```python
class Solution:
    def maxCoins(self, nums: list[int]) -> int:
        
        nums = [1] + nums + [1]
        N = len(nums)

        @cache
        def f(i, j):
            if i > j:
                return 0
            best = 0
            for k in range(i, j+1):
                currentcost = nums[i-1] * nums[k] * nums[j+1]
                left = f(i,k-1)
                right = f(k+1, j)
                best = max(best, left+right+currentcost)
            return best
        
        return f(1, N-2)#pass only original array
```

## 10. Regular Expression Matching

```python
class Solution:
    def isMatch(self, s: str, p: str) -> bool:
        m, n = len(s), len(p)

        # match pattern over string
        @cache
        def f(si, pi):

            if pi == n:
                # reached end of regix and string as well
                return si == m
            
            # why si < m, string can be longer than prefix aaaa|a*
            firstmatch = (si < m and p[pi] in {s[si], '.'})

            if pi+1 < n and p[pi+1] == '*':
                #no atom - still has to match but can skip the si
                op1 = f(si,pi+2) 
                op2 = firstmatch and f(si+1, pi) #reuse the atom
                return op1 or op2

            return firstmatch and f(si+1, pi+1) #normal flow

        return f(0, 0)
```
