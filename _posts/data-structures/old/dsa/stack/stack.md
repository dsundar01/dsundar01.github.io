# Stack

## When to Use
- Matching brackets, parentheses
- Monotonic stack (next greater/smaller element)
- Expression evaluation
- Clue words: "next greater", "valid parentheses", "evaluate", "histogram"

## Templates

<details>
<summary>Next Greater Element (from end, decreasing stack)</summary>

```python
def next_greater_element():
    stack = []
    nge_map = {}
    # next greater start from end
    for i in range(n-1, -1, -1):
        current = nums[i]

        # remove all smaller and place current
        while stack and stack[-1] < current:
            stack.pop()

        nge_map[current] = stack[-1] if stack else -1

        stack.append(current)

    print(dict(sorted(nge_map.items())))
```

</details>

<details>
<summary>Next Smaller Element (from end, increasing stack)</summary>

```python
def next_smaller_element():
    nse_map = {}
    stack = []

    for i in range(n-1, -1, -1):
        current = nums[i]
        # remove all greater and place current (inc stack)
        while stack and stack[-1] >= current:
            stack.pop()

        nse_map[current] = stack[-1] if stack else -1

        stack.append(current)

    print(nse_map)
```

</details>

<details>
<summary>Previous Greater Element (from start, decreasing stack)</summary>

```python
def prev_greater_element():
    stack = []
    pge_map = {}
    for i in range(n):
        current = nums[i]

        # remove all smaller and place current(dec stack - btm)
        while stack and stack[-1] < current:
            stack.pop()

        pge_map[current] = stack[-1] if stack else -1

        stack.append(current)

    print(dict(sorted(pge_map.items())))
```

</details>

<details>
<summary>Previous Smaller Element (from start, increasing stack)</summary>

```python
def prev_smaller_element():
    stack = []
    pse_map = {}
    for i in range(n):
        current = nums[i]

        # remove all greater and place current (inc stack - btm)
        while stack and stack[-1] >= current:
            stack.pop()

        pse_map[current] = stack[-1] if stack else -1

        stack.append(current)

    print(dict(sorted(pse_map.items())))
```

</details>

<details>
<summary>Daily Temperatures</summary>

```python
class Solution:
    def dailyTemperatures(self, t: List[int]) -> List[int]:
        n = len(t)
        stack = []
        res = [0] * n
        for i in range(n-1, -1, -1):
            cur = t[i]
            while stack and t[stack[-1]] <= cur:
                stack.pop()
            res[i] = stack[-1] - i if stack else 0
            stack.append(i)
        
        return res
```

</details>

<details>
<summary>Largest Rectangle in Histogram</summary>

```python
class Solution:

    #next in future, so start from backward
    def nse(self, h):
        n = len(h)
        nse = [0] * n
        stack = []
        for i in range(n-1, -1, -1):
            cur = h[i]
            #want smaller, remove greater which is useless for me 
            # and future because im there
            while stack and h[stack[-1]] >= cur:
                stack.pop()
            nse[i] = stack[-1] if stack else -1
            stack.append(i)
        return nse
    
    #previous lies in past, start from forward
    def pse(self, h):
        n = len(h)
        pse = [0] * n
        stack = []
        for i in range(n):
            cur = h[i]
            while stack and h[stack[-1]] >= cur:
                stack.pop()
            pse[i] = stack[-1] if stack else -1
            stack.append(i)
        return pse
        
    def largestRectangleArea(self, heights: List[int]) -> int:
        n = len(heights)
        nse = self.nse(heights)
        pse = self.pse(heights)
        maxi = 0
        for i in range(n):
            right = n if nse[i] == -1 else nse[i]
            width = right - pse[i] - 1
            maxi = max(maxi, heights[i] * width)
        return maxi
```

</details>

## Key Problems
| Problem | Approach |
|---------|----------|
| Next Greater Element | Monotonic stack |
| Largest Rectangle in Histogram | Monotonic stack of indices |
| Valid Parentheses | Push expected closing bracket |
| Daily Temperatures | Monotonic stack |
| Evaluate Reverse Polish Notation | Stack of operands |
