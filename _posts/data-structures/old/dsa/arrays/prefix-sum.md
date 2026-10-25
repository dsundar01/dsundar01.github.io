# Prefix Sum

## Technique
- <u>**store subarray in hashmap and total sum in variable**</u>
- Range sum queries, Subarray sum, Difference Array, Prefix Matrix
- Subarray sum equals K, Congruence 
- Finding equilibrium index
- Clue words: "subarray sum", "range sum", "cumulative", "running total"

## Template

### Build Prefix Sum
```python
from itertools import accumulate
prefix = list(accumulate(nums, initial=0))
# Sum of nums[l..r] = prefix[r+1] - prefix[l]
```

### Subarray Sum Equals K (HashMap approach)
```python
class Solution:
    def subarraySum(self, nums: List[int], k: int) -> int:

        count = total = 0
        # stores all subarray sums from (0, i)
        sumMap = defaultdict(int)
        sumMap[0] = 1
        for n in nums:
            total += n
            # remove extra subarray in front (prefix)
            if total - k in sumMap:
                count += sumMap[total-k]
            sumMap[total] += 1

        return count
        
```

### 2D Prefix Sum
```python
class NumMatrix:

    def __init__(self, matrix: List[List[int]]):

        if matrix is None or not matrix:
            return

        m,n = len(matrix), len(matrix[0])
        self.prefix = [[0 for _ in range(n)]  for _ in range(m)]

        # computation -> sum from (0,0) to (x,y)
        for i in range(m):
            for j in range(n):
                up = self.prefix[i-1][j] if i > 0 else 0
                left = self.prefix[i][j-1] if j > 0 else 0
                dia = self.prefix[i-1][j-1] if i > 0 and j > 0 else 0
                total = up + left - dia + matrix[i][j]
                self.prefix[i][j] = total

        

    def sumRegion(self, row1: int, col1: int, row2: int, col2: int) -> int:

        total = self.prefix[row2][col2]
        # remove top unwanted row - same column and above row (cell)
        up = self.prefix[row1-1][col2] if row1 > 0 else 0
        # remove left unwanted col -> same row remove before column (cell)
        left = self.prefix[row2][col1-1] if col1 > 0 else 0
        #dia - in up and left -> we removed [row1-1][col1-1] twice
        dia = self.prefix[row1-1][col1-1] if row1 > 0 and col1> 0 else 0

        return total - up - left + dia
        
```

## Key Problems
| Problem | Approach |
|---------|----------|
| Range Sum Query | Prefix array, O(1) per query |
| Subarray Sum Equals K | Prefix + HashMap |
| Contiguous Array | Convert 0→-1, prefix sum + map |
| Product of Array Except Self | Prefix & suffix products |
| 2D Range Sum | 2D prefix sum with inclusion-exclusion |



## My Notes
Prefix Sum	- if extra exists remove and add to result
Prefix Modulo - 	a = b (mod n) if same remainder comes again then inbetween is divisible by n
Prefix Xor -	query[i,j] = prefix[j] - prefix[i-1]
Kadane Algorthim - start new array or continue same array & keep updating max
maxi = max(nums[i], nums[i] + maxi)

[Prefix Sum Matrix](/assets/prefix-sum-matrix.png ':ignore')
[Difference Array](/assets/difference-array.png ':ignore')

https://www.notion.so/23cab1fe3aaa80d59960d656916d9884?v=23cab1fe3aaa807d891a000cbbeddfa3