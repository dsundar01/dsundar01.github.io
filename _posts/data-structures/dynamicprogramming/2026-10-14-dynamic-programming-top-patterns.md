---
title: "Dynamic Programming Top Patterns"
date: 2026-10-14 14:01:20 +05:30
categories: [Data Structures, Dynamic Programming]
tags: []
---


## Core Template

**State** means the information that changes and is needed to solve the smallest/base-case problem.

```python
def f(states):
    answer = initial_value  # min, max, count, or bool

    for option in available_options:
        current_path = f(next_state)
        answer = combine(answer, current_path)

    return answer
```

Dynamic programming is generally:

```text
min / max / count / bool
+
all possible next-state movements in the given state space
```

- **Top-down:** Move to different future states by trying the available options.
- **Bottom-up:** Build the current state using previously solved states.

---

## Dynamic Programming Patterns

| Pattern            | Main idea                                                          | Example                                                                                                                                         |
| ------------------ | ------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| 1D DP              | Array-based previous state, usually Fibonacci style                | [746. Min Cost Climbing Stairs](https://leetcode.com/problems/min-cost-climbing-stairs/)                                                        |
| 0/1 Knapsack       | Pick or skip with a capacity constraint                            | [416. Partition Equal Subset Sum](https://leetcode.com/problems/partition-equal-subset-sum/)                                                    |
| Unbounded Knapsack | Unlimited supply with pick-or-skip and a capacity constraint       | [518. Coin Change II](https://leetcode.com/problems/coin-change-ii/)                                                                            |
| 2D DP              | State movement in given directions                                 | [174. Dungeon Game](https://leetcode.com/problems/dungeon-game/)                                                                                |
| 3D DP              | State movement across nested options                               | [741. Cherry Pickup](https://leetcode.com/problems/cherry-pickup/)                                                                              |
| LIS                | Track the previous value/state to decide the current movement      | [300. Longest Increasing Subsequence](https://leetcode.com/problems/longest-increasing-subsequence/)                                            |
| String DP          | Compare two strings and make decisions                             | [1143. Longest Common Subsequence](https://leetcode.com/problems/longest-common-subsequence/)                                                   |
| Partition DP       | Try all possible subarray cuts                                     | [1547. Minimum Cost to Cut a Stick](https://leetcode.com/problems/minimum-cost-to-cut-a-stick/)                                                 |
| Game DP            | Track the player's turn or use parity                              | [877. Stone Game](https://leetcode.com/problems/stone-game/)                                                                                    |
| State Machine DP   | Track multiple states, such as buy/sell states                     | [309. Best Time to Buy and Sell Stock with Cooldown](https://leetcode.com/problems/best-time-to-buy-and-sell-stock-with-cooldown/)              |
| Tree DP            | Post-order traversal where a node's answer depends on its children | [337. House Robber III](https://github.com/Dhamodharan17/data-structures-algorthims/blob/master/dynamic_programming/readme/1DDP.md)             |
| Shapes DP          | Build answers for geometric shapes in a matrix                     | [221. Maximal Square](https://leetcode.com/problems/maximal-square/)                                                                            |
| Probability DP     | Continue along each branch and sum the stopping probabilities      | [688. Knight Probability in Chessboard](https://leetcode.com/problems/knight-probability-in-chessboard/)                                        |
| Bit DP             | Each state represents a subset of elements                         | [1986. Minimum Number of Work Sessions to Finish the Tasks](https://leetcode.com/problems/minimum-number-of-work-sessions-to-finish-the-tasks/) |
| Digit DP           | A tight flag defines the upper bound                               | [357. Count Numbers with Unique Digits](https://leetcode.com/problems/count-numbers-with-unique-digits/)                                        |

---

## 1D Dynamic Programming

### Top-Down

The current index is the target state. Try every available future option and choose the minimum.

```python
def function(i):
    if i == n - 1:
        return 0

    answer = float("inf")

    for jump in range(1, k + 1):
        nxt = i + jump

        if nxt < n:
            cost = abs(height[i] - height[nxt]) + function(nxt)
            answer = min(answer, cost)

    return answer


return function(0)
```

### Bottom-Up

The current state is built from valid previous states.

```python
dp = [float("inf")] * n
dp[0] = 0

for i in range(1, n):
    for jump in range(1, k + 1):
        if i - jump >= 0:
            cost = dp[i - jump] + abs(height[i] - height[i - jump])
            dp[i] = min(dp[i], cost)

return dp[n - 1]
```

---

## 0/1 Knapsack

An element can be selected only once.

### Top-Down

```python
def isSubsetSum(self, arr, target):
    n = len(arr)

    def f(i, remaining):
        if remaining == 0:
            return True

        if i == n:
            return False

        can_form = False

        for j in range(i, n):
            if arr[j] <= remaining:
                current_path = f(j + 1, remaining - arr[j])
                can_form = can_form or current_path

        return can_form

    return f(0, target)
```

### Bottom-Up

```python
dp = [[False for _ in range(target + 1)] for _ in range(n)]

for i in range(n):
    dp[i][0] = True

if nums[0] <= target:
    dp[0][nums[0]] = True

for i in range(1, n):
    for tar in range(1, target + 1):
        pick = False

        if nums[i] <= tar:
            pick = dp[i - 1][tar - nums[i]]

        skip = dp[i - 1][tar]
        dp[i][tar] = pick or skip

return dp[n - 1][target]
```

---

## State Machine DP: Stock Buy/Sell with Cooldown

### Top-Down

```python
class Solution:
    def maxProfit(self, prices: List[int]) -> int:
        n = len(prices)
        dp = [[-1 for _ in range(2)] for _ in range(n)]

        def util(i, buy):
            if i >= n:
                return 0

            if dp[i][buy] != -1:
                return dp[i][buy]

            if buy == 1:
                profit = max(
                    util(i + 1, 1),
                    -prices[i] + util(i + 1, 0),
                )
            else:
                profit = max(
                    util(i + 1, 0),
                    prices[i] + util(i + 2, 1),
                )

            dp[i][buy] = profit
            return profit

        return util(0, 1)
```

### Bottom-Up Idea

For each day, evaluate the available state movements:

- **Buy:** Buy today using a previously valid state, or continue holding.
- **Sell:** Sell today from a previous holding state, or continue without stock.
- The cooldown determines which earlier state can transition into a buy state.

---

## How to Think About States

1. Form the states using the information provided in the problem.
2. Think about the answer for one state using the bottom-up approach.
3. Think about how to divide the full problem using the top-down approach.

```text
state
  ↓
try every possible action
  ↓
go to the next state
  ↓
take best / sum / min / max
  ↓
store in DP
  ↓
return
```

---

## Four Questions for Every DP Problem

### 1. What uniquely identifies a state?

Examples:

- `i`
- `(i, j)`
- `(i, j, k)`
- `(mask, i)`
- `(node, parent)`

### 2. What choices are available from this state?

List every valid action or transition.

### 3. How should the results of those choices be combined?

Typical operations:

- `max`
- `min`
- `sum`
- `or`

### 4. Can two paths reach the same state?

If yes, memoize the state.

---

## Example DP Breakdown

```text
Target  = n
Need    = different ways, so use count
Options = climb one step or climb two steps
```

Define the state variables needed to solve the smallest/base-case problem. Then try the available transitions and combine their results using `min`, `max`, `count`, or another suitable operation.

---

## Core DP Mindset

First ask:

> What does `dp[i]` represent?

Then ask:

> What smaller states can produce this state?

---

## Top-Down vs Bottom-Up

### Top-Down: Memoization

Think recursively:

> To solve this problem, what smaller problems do I need?

- Write the recursive solution.
- Add memoization.
- Start from the final or large problem and break it down.

### Bottom-Up: Tabulation

Think iteratively:

> What are the smallest states, and how do I build larger states from them?

- Identify the base cases.
- Fill the DP table.
- Reach the final answer.
- Start from small problems and build upward.

### Shortcut

```text
Top-down  = problem -> smaller problems
Bottom-up = small problems -> final problem
```

---

## Choosing the Direction

### Forward: `0 -> N`

Forward movement is natural when the decision at the current state determines costs or effects in future states.

Examples:

- Jump one step or two steps.
- Buy or sell stock today versus tomorrow.
- Pay the current cost and jump forward.

A useful intuition:

> Use forward movement when the current decision can be made now and the rest can be delegated to a future state.

### Backward: `N -> 0`

Backward reasoning is natural when the final goal is fixed and the current value depends on previously solved smaller states.

Examples:

- The `N`th Fibonacci number
- Coin Change for target amount `A`
- Knapsack with capacity `W`

A useful intuition:

> Use backward reasoning when the current state needs values from previous or smaller states before its answer can be determined.

---

## Core Takeaway

The direction does not change the fundamental DP structure. The key is to define:

1. The state
2. The available transitions
3. The base cases
4. How transition results are combined
5. Whether repeated states should be memoized

# Dynamic Programming Patterns

> **Core idea:** Complete the current work and delegate the remaining work to the next state.

---

## 1D Dynamic Programming

**Pattern:** Calculate the current cost and delegate the remaining work using the index and data left.

```python
def minimizeCost(index, arr, k, cache):
    minEnergy = float("inf")

    # From every index, we can go to the next k indices
    for jump in range(1, k + 1):
        previous = index - jump

        if previous >= 0:
            currentEnergy = abs(arr[index] - arr[previous])

            # Delegate the remaining problem
            furtherEnergyRequired = minimizeCost(
                previous, arr, k, cache
            )

            minEnergy = min(
                minEnergy,
                currentEnergy + furtherEnergyRequired
            )

    return minEnergy
```

---

## 2D Dynamic Programming

**Pattern:** Move in the available directions.

```python
def calculateMinimumHP(self, dungeon: List[List[int]]) -> int:
    rows = len(dungeon)
    cols = len(dungeon[0])

    def function(i, j):
        if i == rows - 1 and j == cols - 1:
            return 1 if dungeon[i][j] >= 0 else abs(dungeon[i][j]) + 1

        down = function(i + 1, j)
        right = function(i, j + 1)

        # Minimum health required to reach the next cell
        need_from_previous_cell = min(down, right)

        # Compensate using the current cell
        need = dungeon[i][j] - need_from_previous_cell

        return 1 if need >= 0 else abs(need)

    return function(0, 0)
```

---

## 3D Dynamic Programming

**Pattern:** Try combinations of directions for multiple moving positions.

```python
maxi = float("-inf")

# For each movement of robot 1,
# try every possible movement of robot 2
for di in range(-1, 2):
    for dj in range(-1, 2):

        if j1 == j2:
            answer = grid[i][j1] + f(
                i + 1,
                j1 + di,
                j2 + dj,
                n,
                m,
                grid,
                dp
            )
        else:
            answer = (
                grid[i][j1]
                + grid[i][j2]
                + f(
                    i + 1,
                    j1 + di,
                    j2 + dj,
                    n,
                    m,
                    grid,
                    dp
                )
            )

        maxi = max(maxi, answer)

cache[i][j1][j2] = maxi
return cache[i][j1][j2]
```

---

## Longest Increasing Subsequence

**Pattern:** Track the previous selected element.

```python
def f(i, prev):
    if i == n:
        return 0

    pick = 0

    # Continue the subsequence only when the
    # current element is greater than the previous element
    if prev == -1 or nums[i] > nums[prev]:
        pick = 1 + f(i + 1, i)

    skip = f(i + 1, prev)

    return max(pick, skip)
```

### State

```text
i    = current index
prev = index of the previously selected element
```

---

## Longest Common Subsequence

**Pattern:** Use two pointers and try both possibilities when the characters differ.

```python
def f(i, j):
    if i == m or j == n:
        return 0

    if (i, j) in cache:
        return cache[(i, j)]

    if text1[i] == text2[j]:
        return 1 + f(i + 1, j + 1)

    # Characters do not match, so try both sides
    option1 = f(i + 1, j)
    option2 = f(i, j + 1)

    cache[(i, j)] = max(option1, option2)

    return cache[(i, j)]
```

### State

```text
i = current position in text1
j = current position in text2
```

---

## Substring Dynamic Programming

**Pattern:** Track the consecutive property.

```python
for s1 in range(1, n1 + 1):
    for s2 in range(1, n2 + 1):

        if str1[s1 - 1] == str2[s2 - 1]:
            table[s1][s2] = 1 + table[s1 - 1][s2 - 1]
            longest = max(longest, table[s1][s2])
        else:
            # Consecutive property is lost
            table[s1][s2] = 0
```

Unlike a subsequence, a substring must remain consecutive. Therefore, the value becomes `0` when the characters do not match.

---

## Partition Dynamic Programming

**Pattern:** Try every possible partition point.

```python
class Solution:
    def minCost(self, n: int, cuts: List[int]) -> int:
        cuts = [0] + cuts + [n]
        cuts.sort()

        def f(i, j):
            # No more partitions are possible
            if i > j:
                return 0

            minimum = float("inf")

            # Try every possible cut between i and j
            for k in range(i, j + 1):
                current_cut_cost = cuts[j + 1] - cuts[i - 1]

                left = f(i, k - 1)
                right = f(k + 1, j)

                minimum = min(
                    minimum,
                    current_cut_cost + left + right
                )

            return minimum

        return f(1, len(cuts) - 2)
```

### Transition

```text
Current cost
    = length of the current stick

Total cost
    = current cut cost
    + cost of the left partition
    + cost of the right partition
```

---

## State Machine DP: Stock Buy and Sell with Cooldown

**Pattern:** Track the current day and whether buying is allowed.

```python
def util(i, buy):
    if i >= n:
        return 0

    if dp[i][buy] != -1:
        return dp[i][buy]

    if buy == 1:
        # Either skip buying or buy today
        profit = max(
            util(i + 1, 1),
            -prices[i] + util(i + 1, 0)
        )
    else:
        # Either skip selling or sell today
        profit = max(
            util(i + 1, 0),
            prices[i] + util(i + 2, 1)
        )

    dp[i][buy] = profit
    return dp[i][buy]


return util(0, 1)
```

### State Meaning

```text
buy = 1 -> no stock is held, so buying is allowed
buy = 0 -> stock is held, so selling is allowed
```

### Available Decisions

```text
buy state:
    skip -> util(i + 1, 1)
    buy  -> -prices[i] + util(i + 1, 0)

sell state:
    skip -> util(i + 1, 0)
    sell -> prices[i] + util(i + 2, 1)
```

After selling, the next state starts at `i + 2` because of the one-day cooldown.
