# Binary Search

## Technique
- Sorted array search, Search space reduction
- rotated array → one side is always sorted 
- <u>**upper bound value must > target and lower bound value must ≥ target**</u>
- BS on value
    - <u>**when the input data itself contain the answer**</u>
    - bs on value → find the valid range + apply value on some small logic
    - bs on value → **assume a value to be answer** and try the value to check correctness.
    - find largest minimized → bs on value + lower bound
- Clue words: "sorted", "minimum/maximum that satisfies", "search", "rotated"."minimized maximum"

## Template

### Standard Binary Search
```python
lo, hi = 0, len(nums) - 1
while lo <= hi:
    mid = lo + (hi - lo) // 2
    if nums[mid] == target: return mid
    elif nums[mid] < target: lo = mid + 1
    else: hi = mid - 1
return -1
```

### Lower Bound (first >= target)
```python
lo, hi = 0, len(nums)
while lo < hi:
    mid = lo + (hi - lo) // 2
    if nums[mid] < target: lo = mid + 1
    else: hi = mid
return lo
```

### Binary Search on Answer
```python
lo, hi = min_answer, max_answer
while lo < hi:
    mid = lo + (hi - lo) // 2
    if feasible(mid): hi = mid
    else: lo = mid + 1
return lo
```

### Rotated Sorted Array
```python
lo, hi = 0, len(nums) - 1
while lo <= hi:
    mid = lo + (hi - lo) // 2
    if nums[mid] == target: return mid
    if nums[lo] <= nums[mid]:  # left half sorted
        if nums[lo] <= target < nums[mid]: hi = mid - 1
        else: lo = mid + 1
    else:  # right half sorted
        if nums[mid] < target <= nums[hi]: lo = mid + 1
        else: hi = mid - 1
return -1
```

## Time Based Key-Value Store

<details>
<summary>Find First and Last Position of Element in Sorted Array</summary>

```python
class TimeMap:

    def __init__(self):
        self.store = defaultdict(list)
        

    def set(self, key: str, value: str, timestamp: int) -> None:
        self.store[key].append([value, timestamp])
        

    def get(self, key: str, timestamp: int) -> str:
        values = self.store[key]
        l, r = 0, len(values)-1
        ans = ''
        while l <= r:
            m = (l+r)//2
            #want timestapmaps <=
            if values[m][1] <= timestamp:
                ans = values[m][0]
                l = m + 1
            else:
                r = m - 1
        return ans
```
</details>




## BS on Answer Problems

<details>
<summary>Split Array Largest Sum</summary>

```python
class Solution:
    # minimize the largest subarray sum when splitting into k subarrays
    def splitArray(self, nums: List[int], k: int) -> int:

        def canSplit(maxSum):
            curSum = 0
            curCut = 1
            for n in nums:
                curSum += n
                if curSum > maxSum:
                    curSum = n
                    curCut += 1
            # <= k parts means we can split with this maxSum (or even smaller)
            return curCut <= k

        # Range: lo = max(nums) → at minimum each subarray has at least the largest element
        #        hi = sum(nums) → at most one subarray holds everything
        l, r = max(nums), sum(nums)
        while l < r:
            m = (l + r) // 2
            if canSplit(m):
                # feasible → try smaller maxSum (minimize)
                r = m
            else:
                # can't split into <= k parts → need larger maxSum
                l = m + 1
        return l

```
</details>

<details>
<summary>Aggressive Cows</summary>

```python
class Solution:
    # maximize the minimum distance between any two cows
    def aggressiveCows(self, stalls: List[int], k: int) -> int:
        stalls.sort()

        def canPlace(minDist):
            count = 1
            lastPos = stalls[0]
            for i in range(1, len(stalls)):
                if stalls[i] - lastPos >= minDist:
                    count += 1
                    lastPos = stalls[i]
            return count >= k

        # Range: lo = 1 → minimum possible gap between two stalls
        #        hi = stalls[-1] - stalls[0] → max gap (only 2 cows at endpoints)
        lo, hi = 1, stalls[-1] - stalls[0]
        while lo < hi:
            mid = lo + (hi - lo + 1) // 2  # upper bound (ceiling mid)
            if canPlace(mid):
                # feasible → try larger distance (maximize)
                lo = mid
            else:
                # can't place k cows with this gap → reduce distance
                hi = mid - 1
        return lo
```
</details>

<details>
<summary>Allocate Minimum Pages</summary>

```python
class Solution:
    # minimize the maximum pages any single student reads
    def findPages(self, pages: List[int], k: int) -> int:
        if k > len(pages):
            return -1

        def canAllocate(maxPages):
            students = 1
            curPages = 0
            for p in pages:
                curPages += p
                if curPages > maxPages:
                    students += 1
                    curPages = p
            return students <= k

        # Range: lo = max(pages) → at minimum a student reads the largest book
        #        hi = sum(pages) → at most one student reads all books
        lo, hi = max(pages), sum(pages)
        while lo < hi:
            mid = lo + (hi - lo) // 2
            if canAllocate(mid):
                # feasible → try smaller maxPages (minimize)
                hi = mid
            else:
                # can't fit into <= k students → need more pages per student
                lo = mid + 1
        return lo
```
</details>

## Key Problems
| Problem | Approach |
|---------|----------|
| Search in Rotated Array | Check which half is sorted |
| Find Peak Element | Move toward larger neighbor |
| Koko Eating Bananas | Binary search on answer |
| Median of Two Sorted Arrays | Binary search on partition |
| Search a 2D Matrix | Treat as 1D sorted array |

## My Notes
- 475. Heaters
 bisect_left returns the lower bound (first index where heaters[i] >= v).

heaters[i] = first element ≥ v → lower bound (nearest right)
heaters[i-1] = last element < v → nearest left