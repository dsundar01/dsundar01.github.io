---
title: "Sliding Window Problems"
date: 2026-10-13 20:01:06 +05:30
categories: [Data Structures, Sliding Window]
tags: []
---

## 2653. Sliding Subarray Beauty

>> State : Count Array with Offset + Found Variable

```python
class Solution:
    def getSubarrayBeauty(self, nums: List[int], k: int, x: int) -> List[int]:
        N = len(nums)

        #stores count of each number occurence
        count = [0] * 101 #-50 to 50 (offset so -ve numbers get index)
        def fetchKthSmallest():
            # iterate array of 101 size is O(1)
            totalcount = 0
            for i in range(len(count)):
                totalcount += count[i]
                if totalcount >= x:
                    return i - 50
            return 0

        res = []
        N = len(nums)
        r = l = found = 0
        while r < N:

            # add to state
            cur = nums[r]
            if cur < 0 :
                found += 1
            count[cur+50] += 1

            if r-l+1 == k:
                val = fetchKthSmallest()
                if found >= x:
                    res.append(val)
                else:
                    res.append(0)
                
                # remove from state
                lchar = nums[l]
                if lchar < 0:
                    found -= 1
                count[lchar+50] -=1
                l += 1

            r += 1
        return res
```

## 1423. Maximum Points You Can Obtain from Cards

>> Prefix and Suffix Array

```python
class Solution:
    def maxScore(self, nums: list[int], k: int) -> int:
        n = len(nums)
        prefix = list(accumulate(nums))
        suffix = list(accumulate(nums[::-1]))[::-1]
        maxi = 0

        # This loop tries all possible splits of taking cards from the front and back.
        '''
        1 front + k-1 back
        2 front + k-2 back
        3 front + k-3 back
        ...
        k front + 0 back
        '''
        for i in range(k):
            frontsum = prefix[i]
            # 1 front + k-1 back
            lastk = k-(i+1)
            backsum = suffix[n-lastk] if i < k-1 else 0
            maxi = max(maxi, frontsum+backsum)
        maxi = max(suffix[n-k], maxi)
        return maxi          
```

Take 1 more from front
↓
Need 1 less from back (since n-k always return the last kth blocks)
↓
Suffix start moves right by 1 (i+1)

---
