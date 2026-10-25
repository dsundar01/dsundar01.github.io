# Backtracking

## Technique
- <u>**Generate all valid combinations/permutations**</u>
- <u>**Constraint satisfaction (Sudoku, N-Queens) - Possible Directions**</u>
- Path finding with constraints - <u>**Inject Conditions**</u> E.g. No leading zero, palindrome
- Clue words: "all possible", "generate", "combinations", "permutations"

## Template

### Pick/Skip Pattern
```python
#recursion utility
def util(idx, temp):
    if idx == N:
        result.append(list(temp))
        return
    #pick
    temp.append(nums[idx])
    util(idx+1, temp)
    #skip
    temp.pop()
    util(idx+1, temp)

N, result = len(nums), []
util(0, [])
return result
```

### Permutations
```python
def f(used):
    if len(arr) == len(used):
        print(used)
        return
    # all elements can be chosen at a point based on path
    for a in arr:
        # only unused paths are allowed
        if a not in used:
            used.append(a)
            f(used)
            used.pop()
```

### String Formation
```python 
def splitstring(idx, s, result):
    
    if idx == len(s):
        print(result)
        return
    
    for i in range(idx, len(s)):
    # idx to i
        result.append(s[idx:i+1])
        splitstring(i+1, s,result)
        result.pop()

splitstring(0,'199100199',[])  

```

## Key Concepts
- **Choose → Explore → Unchoose** pattern
- Pruning: skip invalid states early to reduce search space
- For duplicates: sort array + `if (i > start && nums[i] == nums[i-1]) continue;`

## Problems

<details>
<summary>Palindrome Partitioning</summary>

```python
class Solution:
    def partition(self, s: str) -> List[List[str]]:
        def f(i, res):
            if i == n:
                ans.append(list(res))
                return
            for j in range(i, n):
                curstr = s[i:j+1]
                #don't allow it is not palindrome
                if curstr != curstr[::-1]:
                    continue
                res.append(curstr)
                f(j+1, res)
                res.pop()
        n = len(s)
        ans = []
        f(0, [])
        return ans
```
</details>


## Key Problems
| Problem | Approach |
|---------|----------|
| Subsets | Include/exclude each element |
| Permutations | Use visited array |
| N-Queens | Row by row, validate column/diagonal |
| Sudoku Solver | Cell by cell, try 1-9 |
| Word Search | DFS on grid with backtracking |

