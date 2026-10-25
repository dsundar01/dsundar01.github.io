# HashMap

## Technique
- Frequency counting & Two Sum type lookups
- <u>**Almost can be used with any data structure**</u>
- Grouping / anagram detection (<u>**Anagram - same char and char count, sorting makes all equal**</u>)
- Clue words: "frequency", "count", "group", "anagram", "two sum"

## Templates

### Two Sum
```python
class Solution:
    def twoSum(self, nums: List[int], target: int) -> List[int]:
        #x+y = target -> x = target-y
        xMap = defaultdict(int)

        for i, y in enumerate(nums):
            x = target - y
            if x in xMap:
                return [xMap[x], i]
            xMap[y] = i
        return []
        
```

### Group Anagrams
```python
class Solution:
    def groupAnagrams(self, strs: List[str]) -> List[List[str]]:
        anagramMap = defaultdict(list)
        for s in strs:
            #sorted(s) return array
            anagramMap[tuple(sorted(s))].append(s)
        return [ v for v in anagramMap.values()]
        
```

### Longest Consecutive Sequence
```python
class Solution:
    def longestConsecutive(self, nums: List[int]) -> int:
        numSet = set(nums)
        maxi = 0
        for n in numSet:
            # allow only starts
            if n-1 in numSet:
                continue
            leng = 1
            # keep searching consective elements
            while n+leng in numSet:
                leng += 1
            # update count of consective elements
            maxi = max(maxi, leng)
        return maxi
        
```

## Key Problems
| Problem | Approach |
|---------|----------|
| Two Sum | Map value → index |
| Group Anagrams | Sorted string as key |
| Longest Consecutive Sequence | HashSet, find sequence starts |
| Top K Frequent Elements | Frequency map + heap |
| LRU Cache | HashMap + Doubly Linked List |
