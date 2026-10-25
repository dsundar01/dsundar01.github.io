# Sliding Window

## Technique
- <u>**Slide & Undo Effect with some external data structure or math property**</u>
- <u>**Right Expands & Left Shrinks**</u>
- External data structure : Stack, Heap, Deque, HashMap, Boolean Array, Total Sum Variable, Sorting
- Subarray / substring problems with a **condition** (max/min length, sum ≥ k, at most k distinct)
- Contiguous elements only
- Clue words: "subarray", "substring", "window", "consecutive"

## Template

### Fixed Size Window
```python
class Solution:
    def maxSlidingWindow(self, nums: List[int], k: int) -> List[int]:
        # external data strcture - deque
        n, res, dq = len(nums), [], deque()
        l = r = 0

        while r < n:
            while dq and dq[0] < l:
                dq.popleft()
            cur = nums[r]
            while dq and nums[dq[-1]] < cur:
                dq.pop()
            dq.append(r)
            if r-l+1 == k:
                res.append(nums[dq[0]])
                l += 1 #shrink
            r += 1 #expand
        return res
    
        
```

### Variable Size Window
```python
class Solution:
    def minWindow(self, s: str, t: str) -> str:
        # external data strcture - hashmap
        tcount, scount = Counter(t),  Counter()
        l = r = found = 0
        mini,sIndexm n = 10**9, -1, len(s)

        while r < n:
            scount[s[r]] += 1
            if s[r] in tcount and tcount[s[r]] == scount[s[r]]:
                found += 1
            #since we increase found once it complely satify count
            while found == len(tcount):
                winLen = r-l+1
                if winLen < mini:
                    mini = winLen
                    sIndex = l
                #shrink left
                lc = s[l]
                scount[lc] -= 1
                if lc in tcount and tcount[lc] > scount[lc]:
                    found -= 1 #only when target reduces
                l += 1 #shrink
            r += 1 #expand
        
        return s[sIndex:sIndex+mini] if sIndex != -1 else ''

        
```

## Complexity
- **Time:** O(n) — each element enters and leaves window once
- **Space:** O(1) or O(k) if using a map/set

## Edge Cases
- Empty array
- Window size > array length
- All elements same
- Entire array is the answer

## Problems

| # | Problem | Difficulty | Key Trick |
|---|---|---|---|
| 1 | Max Sum Subarray of Size K | Easy | Fixed window |
| 2 | Longest Substring Without Repeating Chars | Medium | HashSet + variable window |
| 3 | Minimum Size Subarray Sum | Medium | Variable window, shrink when sum ≥ target |
| 4 | Longest Repeating Character Replacement | Medium | Track maxFreq, shrink when window - maxFreq > k |
| 5 | Minimum Window Substring | Hard | Two maps, track "formed" count |

## My Notes
<!-- Add your own observations, mistakes, and learnings below -->
page    451
