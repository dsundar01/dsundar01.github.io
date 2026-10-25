# Dynamic Programming
## Technique
- <u>**Dynamic Loops ; f(x) -> define the function (solve the smallest problem)**</u>
- Problems : Knapsack, Unbounded Knapsack, Min/Max among all, Count number of ways, Possible or not
- Clue words: "subset sum", "partition", "target sum", "profit", "capacity"

## Approach

- <u>**Finding the correct base cases (direct answers) is the real thinking job**</u>
- <u>**"What are the smallest subproblems I can solve directly?"**</u>
- Everything else follows.
- "For which inputs do I already KNOW the answer without recursion?"
- That depends on problem understanding and pattern recognition.

### Quick mental checklist
When writing recursion:
1. **Define recurrence** → e.g. Coin Change: `f(amount) = min(f(amount - coin) + 1) for all coins` 
    -  "What is the minimum number of coins to make this amount?"
2. **Ask: smallest meaningful input?** → e.g. `amount=0` (no coins needed)
3. **Write direct answers for those** → e.g. `f(0)=0`, `f(negative)=∞`
4. (Guarding automatically handled) → e.g. `if amount < 0: return float('inf')`

### Simple analogy
Think of it like building stairs itself:
1. **Substructure** → how steps connect
2. **Base case** → where ground starts
3. **Guarding** → don't dig below ground

## Template

<details>
<summary>1D DP</summary>

```python
def minimizeCost(index, arr, k, cache):

    if index < 0: return float('inf')  # no way to reach n

    if cache[index] is not None: return cache[index]

    if index == 0:
        cache[index] = 0
        return 0  # energy required to reach 0 from 0

    minEnergy = float('inf')
    # from every index we can go to next k index
    for i in range(1, k + 1):

        # jump should be valid
        if index < i: continue  # if index is smaller then i will get -ve index
        # jump linearly till k
        currentEnergy = abs(arr[index] - arr[index - i])
        # find energy lost from index+i to end
        furtherEnergyRequired = minimizeCost(index - i, arr, k, cache) #recursion

        minEnergy = min(minEnergy, currentEnergy + furtherEnergyRequired)

    cache[index] = minEnergy
    return minEnergy
```
</details>

<details>
<summary>2D DP</summary>

```python
class Solution:
    def calculateMinimumHP(self, dungeon: List[List[int]]) -> int:

        M, N = len(dungeon), len(dungeon[0])
        @lru_cache
        def function(i,j):

            if i >= M or j >= N:
                return 10**9
            
            if i == M-1 and j == N-1:
                return 1 if dungeon[i][j] >=0 else abs(dungeon[i][j])+1

            down = function(i+1,j)
            right = function(i, j+1)
            # minimum energy required to reach next cell
            need_from_prev_cell = min(down, right)
            #try to compensate
            need = dungeon[i][j] - need_from_prev_cell

            return 1 if need >=0 else abs(need)
        
        return function(0,0)
```
</details>

<details>
<summary>3D DP</summary>

```python
def maxChocolate(i, j1, j2, n, m, grid, cache):

    # basecase 1
    if j1 < 0 or j1 >= m or j2 < 0 or j2 >= m: return float('-inf')

    if cache[i][j1][j2] is not None: return cache[i][j1][j2]

    # basecase 2 - last row
    if i == n - 1:
        # only one chocolate counted
        if j1 == j2:
            cache[i][j1][j2] = grid[i][j1]
        else:
            # both got chocolate
            cache[i][j1][j2] = grid[i][j1] + grid[i][j2]
        return cache[i][j1][j2]

    maxi = float('-inf')
    # for each position of robot 1 try all other for robot2
    for di in range(-1, 2):#-1, 0, 1
        for dj in range(-1, 2):
            if j1 == j2:
                ans = grid[i][j1] + maxChocolate(i + 1, j1 + di, j2 + dj, n, m, grid, cache)
                # increase row and try directions
            else:
                ans = grid[i][j1] + grid[i][j2] + maxChocolate(i + 1, j1 + di, j2 + dj, n, m, grid, cache)

            maxi = max(maxi, ans)

    cache[i][j1][j2] = maxi
    return cache[i][j1][j2]
```
</details>

<details>
<summary>Subset DP</summary>

```python
def isSubset(index, arr, s, cache):

    if s == 0: return True

    if index == len(arr): return False

    # return already cached value
    if cache[index][s] is not None: return cache[index][s]

    # pick the value
    selected = False
    if arr[index] <= s:
        selected = isSubset(index + 1, arr, s - arr[index], cache)

    # skip the value
    skipped = isSubset(index + 1, arr, s, cache)

    cache[index][s] = selected or skipped  # if any one true -> true
    return cache[index][s]
```
</details>

<details>
<summary>UnBound Knapsack</summary>

```python
class Solution:

    def util(self, curIndex, curAmount):
        
        if curAmount == 0:
            return 1
        if curAmount < 0 or curIndex == len(self.coins):
            return 0
        count = 0
        #try current and further coins
        for i in range(curIndex,len(self.coins)):
            if self.coins[i] <= curAmount:
                #next i starts after current i hits base condition
                count += self.util(i,curAmount-self.coins[i])
        return count

    def change(self, amount: int, coins: List[int]) -> int:
        self.coins = coins
        return self.util(0, amount)
```
</details>

<details>
<summary>DP on Subsequence - LIS</summary>

```python
class Solution:
    def lengthOfLIS(self, nums: List[int]) -> int:

        n = len(nums)
        # longest stricly increasing subseq starting at i
        def f(i, prev):
            if i == n:
                return 0
            pick = 0
            # allow subseq to cotinue is current > prev (LIS)
            if prev == -1 or nums[i] > nums[prev]: 
                pick = 1 + f(i+1, i)
            skip =f(i+1,prev)
            return max(pick, skip)
        
        return f(0,-1)
```
</details>

<details>
<summary>DP on Strings - LCS</summary>

```python
class Solution:
    def longestCommonSubsequence(self, text1: str, text2: str) -> int:

        cache =  {}
        #longest common seq start at i and j
        def f(i, j):
            
            if i == m or j == n:
                return 0
            if (i, j) in cache:
                return cache[(i,j)]

            if text1[i] == text2[j]:
                return 1 + f(i+1, j+1)
            # when not equal try both sides & take max
            op1 = f(i+1, j) 
            op2 = f(i, j+1)
            cache[(i,j)] = max(op1, op2)
            return cache[(i,j)]
        
        m, n = len(text1), len(text2)
        return f(0,0)
```

```python
def longestCommonSubstr(str1, str2):
    n1 = len(str1)
    n2 = len(str2)

    table = [[0] * (n2 + 1) for _ in range(n1 + 1)]
    lcs = 0

    for s1 in range(1, n1 + 1):
        for s2 in range(1, n2 + 1):
            if str1[s1 - 1] == str2[s2 - 1]:
                table[s1][s2] = 1 + table[s1 - 1][s2 - 1]
                lcs = max(lcs, table[s1][s2])
            else:
                # consecutive property lost
                table[s1][s2] = 0

    return lcs
```
</details>

<details>
<summary>Partition DP - MCM</summary>

```python
class Solution:
    def minCost(self, n: int, cuts: List[int]) -> int:
        cuts = [0] + cuts + [n]
        cuts.sort()

        def f(i, j):
            #no more partition possible
            if i > j:
                return 0
            maxi  = 10**9 #min cost to cut  in range(i,j)
            for k in range(i,j+1):
                curcutcost = cuts[j+1] - cuts[i-1] #length of stick
                l = f(i,k-1)
                r = f(k+1,j)
                maxi = min(maxi, curcutcost+l+r)
            return maxi
        
        return f(1, len(cuts)-2)
```
</details>

<details>
<summary>Stocks DP</summary>

```python
class Solution:
    def maxProfit(self, prices: List[int]) -> int:

        n = len(prices)
        dp = [ [ -1 for _ in range(2)] for _ in range(n)]
        # buy=1 means we CAN buy, buy=0 means we are HOLDING (can sell)
        # After selling, skip next day (cooldown) → util(i+2, 1)
        def util(i, buy):

            if i >= n:
                return 0

            if dp[i][buy] != -1:
                return dp[i][buy]

            if buy == 1:  # can buy
                profit = max(
                    util(i+1, 1),             # skip (don't buy today)
                    -prices[i] + util(i+1, 0) # buy today → pay price, next state = holding
                )
            else:  # buy == 0, holding → can sell
                profit = max(
                    util(i+1, 0),             # skip (don't sell today)
                    prices[i] + util(i+2, 1)  # sell today → gain price, cooldown 1 day
                )

            dp[i][buy] = profit
            return dp[i][buy]
        
        return util(0, 1)  # start with ability to buy
```
</details>

<!-- ## Problems

| # | Problem | Difficulty | Variant |
|---|---|---|---|
| 1 | Subset Sum | Medium | 0/1 (boolean dp) |
| 2 | Partition Equal Subset Sum | Medium | 0/1 (target = totalSum/2) |
| 3 | Coin Change | Medium | Unbounded (min coins) |
| 4 | Coin Change 2 (count ways) | Medium | Unbounded (count) |
| 5 | Target Sum | Medium | 0/1 (convert to subset sum) | -->

## My Notes
<!-- Add your own observations, mistakes, and learnings below -->

