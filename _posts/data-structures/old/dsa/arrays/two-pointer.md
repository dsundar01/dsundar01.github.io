# Two Pointer

## Technique
- Start from <u>**both ends in sorted array or axis parallel strings/array**</u> (pure while loop)
- Sorted array problems, Palindrome, Reverse, Axis Parallel, 2 Pointer(winner)
- Maths, Hashmap, Math formulas being used to count with certain property like sorteds, parabola, sort both given input
- Clue words: "pair", "sorted", "in-place", "two sum", "three sum"


## Template

### Opposite Direction (sorted array)
```python
class Solution:
    def threeSum(self, nums: list[int]) -> list[list[int]]:
        res = []
        n = len(nums)
        nums.sort() #sort to get the sum property
        for i in range(n):
            if i > 0 and nums[i-1] == nums[i]:
                continue
            l, r = i+1, n-1
            while l < r:
                t = nums[i]+nums[l]+nums[r]
                if t == 0:
                    res.append([nums[i],nums[l],nums[r]])
                    #l += 1
                    while l < r and nums[l] == nums[l+1]:
                        l += 1 #lands at non dup
                    l += 1
                    #r -= 1
                    while l < r and nums[r] == nums[r-1]:
                        r -= 1 #lands at non dup
                    r -= 1
                elif t > 0:
                    r -= 1 #remove the larger value, need less value
                else:
                    l += 1 # remove the smaller, need more value
        return res

        
```

## Complexity
- **Time:** O(n) for two pointers, O(n²) for 3Sum
- **Space:** O(1)

## Edge Cases
- Array with < 2 elements
- All elements same
- Negative numbers (for sum problems)
- Duplicates — skip with `while (left < right && nums[left] == nums[left-1]) left++`

## Problems

| # | Problem | Difficulty | Key Trick |
|---|---|---|---|
| 1 | Two Sum II (sorted) | Easy | Opposite pointers |
| 2 | Remove Duplicates from Sorted Array | Easy | Fast-slow pointer |
| 3 | 3Sum | Medium | Fix one + two pointer |
| 4 | Container With Most Water | Medium | Move shorter side inward |
| 5 | Trapping Rain Water | Hard | Left/right max tracking |

## My Notes
<!-- Add your own observations, mistakes, and learnings below -->
- `count += right - left` → if `nums[L]+nums[R] < target`, all pairs (L, L+1..R) are valid since array is sorted
- Example: L=0, R=5 → pairs (0,1),(0,2),(0,3),(0,4),(0,5) = 5 pairs
- After counting all pairs for L, do `L += 1`

## Problems Notes

<details>
<summary>475. Heaters</summary>

The two-pointer approach for Heaters:

1. Sort both `houses` and `heaters`
2. Use one pointer for houses, one for heaters
3. For each house, advance the heater pointer while the next heater is closer (or equally close)

```python
def findRadius(self, houses, heaters):
    houses.sort()
    heaters.sort()
    maxi = 0
    j = 0  # heater pointer
    for house in houses:
        # move to closest heater for this house
        while j + 1 < len(heaters) and abs(heaters[j+1] - house) <= abs(heaters[j] - house):
            j += 1
        maxi = max(maxi, abs(heaters[j] - house))
    return maxi
```

**Why two pointers works:** Since both arrays are sorted, as houses increase left→right, the optimal heater can only stay the same or move right — it never goes backward. So the heater pointer only advances forward, giving O(n + m) after sorting.

The binary search approach (O(n log m)) and two-pointer approach (O(n log n + m log m)) are both valid — LeetCode tags it under both categories.

</details>
