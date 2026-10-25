# Intervals

## Technique
- <u>**Sorting Interval, Hashmap(line sweep), 2 Pointer(winner), Min Heap.**</u>
- Clue words: "interval", "overlap", "merge", "schedule", "meeting"

## Template

### Merge Intervals
```python
class Solution:
    def insert(self, intervals: List[List[int]], newInterval: List[int]) -> List[List[int]]:

        res = []
        n = len(intervals)
        for i in range(n):

            #non overlapping case 2 - old interval the newinterval
            if not newInterval or intervals[i][1] < newInterval[0]:
                res.append(intervals[i])

            #non overlap case 1 -> new interval the old interval
            elif newInterval[1] < intervals[i][0]:
                res.append(newInterval)
                res.append(intervals[i])
                newInterval = None
            
            else:
                newInterval[0] = min(newInterval[0], intervals[i][0])
                newInterval[1] = max(newInterval[1], intervals[i][1])
        
        if newInterval:
            res.append(newInterval)
        return res
            
        
```

### Line Sweep
```python
class Solution:
    def employeeFreeTime(self, schedule: '[[Interval]]') -> '[Interval]':
        
        eventMap = defaultdict(int)
        M, N = len(schedule), len(schedule[0])
        for i in range(M):
            for j in range(len(schedule[i])):
                start = schedule[i][j].start
                end = schedule[i][j].end
                eventMap[start] += 1
                eventMap[end] -= 1
        
        start = 0
        result = []
        sweepLine  = 0 # monitors event
        flag = 0
        for k, v in sorted(eventMap.items()):
            sweepLine += v
            # if 0 -> after event means end of some event
            if sweepLine == 0:
                start = k
                flag = 1
            # new event start after some free time (0---free--somevalue(event start))
            elif sweepLine > 0 and flag:
                result.append(Interval(start,k))
                flag = 0
        
        return result    
```

### Interval Sorting Problems
```python
# sort interval start, end based on problem need ,after thinking
    intervals.sort(key=lambda x: (x[0], -x[1])) #sort asc, if same sort desc of x[1]
```
## Key Problems
| Problem | Approach |
|---------|----------|
| Merge Intervals | Sort by start, merge overlapping |
| Insert Interval | Add before, merge overlap, add after |
| Meeting Rooms | Sort, check no overlap |
| Meeting Rooms II | Min heap on end times |
| Non-overlapping Intervals | Greedy, sort by end, count removals |

## My Notes

[Line Sweep Explanation](/assets/interval-line-sweep.png ':ignore')
