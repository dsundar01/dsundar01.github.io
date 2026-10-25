# Greedy

## Technique
- Locally optimal → globally optimal
- <u>**sorting & heaps often comes & swaps, traversing from right to left, left to right and keeping max/min, suffix array, 2 pointer, mono stack**</u>
- Greedy = choosing the best option at each step, trusting it leads to the overall best answer.
- Clue words: "minimum cost", "maximum profit", "schedule", "optimal"

## Template

### Jump Game 2
```python
class Solution:
    def jump(self, nums: List[int]) -> int:
        
        jump, maxJump, count = nums[0], nums[0], 1
        if len(nums) == 1:
            return 0
        for i in range(1,len(nums)-1):
            cur = nums[i]
            #reduce both jumps
            jump -= 1
            maxJump -= 1
            #keep max updated
            maxJump = max(maxJump, cur)
            if jump == 0:
                #use
                count += 1
                jump = maxJump
        return count
        
```

### Jump Game 3
```python
import heapq

class Solution:
    def minRefuelStops(self, target: int, startFuel: int, stations: List[List[int]]) -> int:

        stations.append([target, 0])  # treat target as a station
        maxHeap = []
        curFuel = startFuel
        prevPos = 0
        refill = 0

        for pos, gas in stations:

            # distance from last visited position
            dist = pos - prevPos

            # need to travel dist, so check fuel
            while curFuel < dist:
                if not maxHeap:
                    return -1 #no more backup
                #refill
                curFuel += -heapq.heappop(maxHeap)
                refill += 1

            # travel to this station
            curFuel -= dist
            prevPos = pos

            # push this station’s fuel for future use
            heapq.heappush(maxHeap, -gas)

        return refill
```

### Max Swap
```python
'''
Greedy choice = swap the leftmost small digit with the rightmost largest digit after it → maximizes the number in one swap.
'''
class Solution:
    def maximumSwap(self, num: int) -> int:

        num = list(str(num))

        max_digit = "0" #since we have intial index as -1
        max_i = -1
        swap_i = swap_j = -1

        for i in reversed(range(len(num))):

            #max
            if num[i] > max_digit:
                max_digit = num[i]
                max_i = i

            #min for swap
            if num[i] < max_digit:
                swap_i, swap_j = i, max_i
        
        num[swap_i], num[swap_j] = num[swap_j], num[swap_i]

        return int("".join(num))
            

        
```

## Key Problems
| Problem | Approach |
|---------|----------|
| Jump Game | Track farthest reachable |
| Jump Game II | BFS-like greedy |
| Gas Station | Track surplus, reset on negative |
| Task Scheduler | Most frequent task first |
| Assign Cookies | Sort both, match smallest |

## My Notes
- https://www.notion.so/227ab1fe3aaa804b8227ccc4214f6ef9?v=227ab1fe3aaa806eaa1e000cd78cf68e
- https://www.notion.so/Greedy-coding-stamina-2deab1fe3aaa80d1a9c8f7b8e5cec6ec
- https://www.notion.so/Greedy-336ab1fe3aaa806aa85fddac83b0f0f6
