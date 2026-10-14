---
title: "Binary Search"
date: 2026-10-14 15:51:10 +05:30
categories: [Data Structures, Binary Search]
tags: [neetcode]
---

## Binary Search

```python
class Solution:
    def search(self, nums: list[int], target: int) -> int:
        N = len(nums)
        l, r = 0, N-1
        while l <= r:
            m = (l+r)//2
            if nums[m] == target:
                return m
            if nums[m] > target:
                r = m-1
            else:
                l = m+1
        return -1
```

## Binary Search on 2D Matrix

```python
class Solution:
    def searchMatrix(self, matrix: list[list[int]], target: int) -> bool:
        m, n = len(matrix), len(matrix[0])

        def bs(arr):
            l, r = 0, len(arr)-1
            while l <= r:
                m2 = (l+r)//2
                if arr[m2] == target:
                    return True
                if arr[m2] > target:
                    r = m2-1
                else:
                    l = m2+1
            return False

        l, r = 0, m-1
        while l <= r:
            mi = (l+r)//2
            # find the row our target lies
            if matrix[mi][0] <= target <= matrix[mi][n-1]:
                return bs(matrix[mi])
            elif matrix[mi][0] > target:
                r = mi-1
            else:
                l = mi+1
        return False       
```

## Koko Eating Banana

```python
class Solution:
    def minEatingSpeed(self, piles: list[int], h: int) -> int:
        N = len(piles)
        #find the speed (numbers to take) to complete within h
        def isValid(m):
            total = 0
            for p in piles:
                total += math.ceil(p/m)
            # after check with given max time
            return total <= h

        l, r = 1, max(piles)
        while l < r:
            m = (l+r)//2
            if isValid(m):
                r = m
            else:
                l = m+1
        return l
```

## 153. Find Minimum in Rotated Sorted Array

```python
class Solution:
    def findMin(self, nums: list[int]) -> int:
        # fact : one side is sorted
        l, r = 0, len(nums)-1
        mini = 10**9
        while l <= r:
            m = (l+r)//2
            if nums[l] <= nums[m]:
                mini = min(mini, nums[l])
                #go other unsorted side
                l = m+1
            else:
                mini = min(mini, nums[m])
                r = m-1
        return mini
```

## 33. Search in Rotated Sorted Array

```python
class Solution:
    def search(self, nums: list[int], target: int) -> int:
        l, r = 0, len(nums)-1
        while l <= r:
            m = (l+r)//2
            if nums[m] == target:
                return m
            # look on the sorted side 1st
            if nums[l] <= nums[m]:
                if nums[l] <= target <= nums[m]:
                    r = m-1
                else:
                    l = m+1
            else:
                if nums[m] <= target <= nums[r]:
                    l = m+1
                else:
                    r = m-1
        return -1
```

## 981. Time Based Key-Value Store

```python
class TimeMap:

    def __init__(self):
        self.data = defaultdict(list)
        

    def set(self, key: str, value: str, timestamp: int) -> None:
        self.data[key].append((timestamp, value))
        

    def get(self, key: str, timestamp: int) -> str:
        target = self.data[key]
        # upper bound strictly greater >, so left is 1st smaller
        idx = bisect.bisect_right(target, timestamp, key = lambda r:r[0])
        # if no left then no answer
        if idx == 0:
            return ""
        else:
            return target[idx-1][1]
```

## Median of Two Sorted Arrays

```python
class Solution:
    def findMedianSortedArrays(self, nums1: List[int], nums2: List[int]) -> float:

        #median of 2 sorted array after merge
        #hint - sorted array
        n1, n2 = len(nums1), len(nums2)

        if n1 > n2 : return self.findMedianSortedArrays(nums2, nums1)

        n = n1 + n2
        left = (n1+n2+1)// 2
        low, high = 0, n1

        while low <= high:

            mid1 = (low + high) // 2
            mid2 = left - mid1

            # left part of both arrays
            l1 = nums1[mid1-1] if mid1 >0 else float('-inf')
            l2 = nums2[mid2-1] if mid2 > 0 else float('-inf')

            #right part of both arrays
            r1 = nums1[mid1] if mid1 < n1 else float('inf')
            r2 = nums2[mid2] if mid2 < n2 else float('inf')

            # all element in left should be smaller then right
            if l1 <= r2 and l2 <= r1:

                if n % 2 == 1:return max(l1,l2)

                else:return (max(l1, l2) + min(r1, r2)) / 2.0

            # array 1 has more -> reduce it, keep array 2 as it 
            # unselect from main array
            elif l1 > r2:
                high = mid1 - 1
            # array 2 has more -> increase it 
            # select more from another array
            elif l2 > r1:
                low = mid1 + 1

        return 0
```
