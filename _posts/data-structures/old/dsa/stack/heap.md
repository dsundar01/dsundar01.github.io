# Heap / Priority Queue

## When to Use
- Top K elements
- Merge K sorted lists
- Running median
- Clue words: "top k", "kth largest", "merge sorted", "median", "schedule"

## Implementation
```python
class MinHeap:
    def __init__(self, capacity):
        self.size = 0
        self.capacity = capacity
        self.arr = [0] * capacity

    def parent(self, i): return (i - 1) // 2
    def left(self, i): return 2 * i + 1
    def right(self, i): return 2 * i + 2

    # extract min
    def extract_min(self):
        if self.size == 0: return -1

        temp = self.arr[0]  # remove top
        self.arr[0] = self.arr[self.size - 1]
        self.size -= 1
        self.heapify(0)
        return temp
    # top down
    def heapify(self, i):
        smallest = i
        l = self.left(i)
        r = self.right(i)

        if r < self.size and self.arr[smallest] > self.arr[r]:
            smallest = r
        if l < self.size and self.arr[smallest] > self.arr[l]:
            smallest = l

        if smallest != i:
            self.arr[smallest], self.arr[i] = self.arr[i], self.arr[smallest]
            self.heapify(smallest)

    # insert at last index
    def insert(self, val):
        if self.size == self.capacity: return

        k = self.size  # for heapify
        self.arr[self.size] = val  # insert new value at end
        self.size += 1  # increase size
        
        # bottom up
        while k != 0 and self.arr[k] < self.arr[self.parent(k)]:
            self.arr[k], self.arr[self.parent(k)] = self.arr[self.parent(k)], self.arr[k]
            k = self.parent(k)

    def get_min(self):
        return self.arr[0] if self.size > 0 else -1
```

## Templates

### Top K Frequent Elements
```python
class Solution:
    def topKFrequent(self, nums: List[int], K: int) -> List[int]:
        numCounter = Counter(nums)
        #to remove min count number
        minHeap = []
        for k, v in numCounter.items():
            #allow till k-1
            if len(minHeap) == K:
                if minHeap[0][0] < v:#heap top
                    heapq.heapreplace(minHeap,(v,k))
            else:
                heapq.heappush(minHeap, (v,k))
        
        return [x[1] for x in minHeap[:K]]
```

### Kth Largest Element
```python
import heapq

class Solution:
    def findKthLargest(self, nums: List[int], k: int) -> int:
        minHeap = []
        for num in nums:
            heapq.heappush(minHeap, num)
            if len(minHeap) > k:
                heapq.heappop(minHeap)
        return minHeap[0]
```

### Merge K Sorted Lists
```python
import heapq

class Solution:
    def mergeKLists(self, lists: List[Optional[ListNode]]) -> Optional[ListNode]:
        pq = []
        for i, node in enumerate(lists):
            if node:
                heapq.heappush(pq, (node.val, i, node))

        dummy = ListNode(0)
        curr = dummy
        while pq:
            val, i, node = heapq.heappop(pq)
            curr.next = node
            curr = curr.next
            if node.next:
                heapq.heappush(pq, (node.next.val, i, node.next))
        return dummy.next
```

### Running Median (Two Heaps)
```python
import heapq

class MedianFinder:
    def __init__(self):
        self.maxHeap = []  # lower half (negate for max heap)
        self.minHeap = []  # upper half

    def addNum(self, num: int) -> None:
        heapq.heappush(self.maxHeap, -num)
        heapq.heappush(self.minHeap, -heapq.heappop(self.maxHeap))
        if len(self.minHeap) > len(self.maxHeap):
            heapq.heappush(self.maxHeap, -heapq.heappop(self.minHeap))

    def findMedian(self) -> float:
        if len(self.maxHeap) > len(self.minHeap):
            return -self.maxHeap[0]
        return (-self.maxHeap[0] + self.minHeap[0]) / 2.0
```
### Heap
```python
class Solution:
    def findMaximizedCapital(self, k, w, p, c) -> int:

        pc = list(zip(c,p))
        pc.sort()
        i = 0
        mxHeap = []
        #select k project
        for _ in range(k):
            
            #push only budget projects
            while i < len(pc) and pc[i][0] <= w:
                heapq.heappush(mxHeap, -pc[i][1])
                i += 1
            if mxHeap:
                w += (-heapq.heappop(mxHeap))
        
        return w
```
## Key Problems
| Problem | Approach |
|---------|----------|
| Kth Largest in Stream | Min heap of size K |
| Top K Frequent Elements | Min heap by frequency |
| Merge K Sorted Lists | Min heap of list heads |
| Find Median from Data Stream | Max heap + Min heap |
| Meeting Rooms II | Min heap on end times |
