# Linked List

<u>**Basic Operations**</u>
1. Singly Linkedlist
    1. delete, insert
        1. Recursion
            1. directly go to the node in recursion and manipulate
        2. Iterative
            1. <u>**to manipulate kth node, we need k-1th reference, to get k-1th reference we need to iterate k-2 times**</u>
    2. <u>**to reach kth node -> iterate k-1 times**</u>
        - stop (1-k-1) for 1 based index
    3. <u>**delete -> skip (head.next = head.next.next)**</u>
2. DLL
    - insert at end - > temp.next = newNode ; newNode.prev = temp
    - <u>**insert in between 4 pointer changes**</u>
        - newnode.next = temp.next; newnode.prev = temp
        - temp.next.prev = newnode ; temp.next = newnode
    - <u>**delete in between**</u>
        - target.prev.next = target.next
        - target.next.prev = target.prev

## Techniques
- Sequential access, frequent insert/delete
- Cycle detection, reversal, merge
- Slow and Fast Pointer, 2 Pointer, Sorting, Hashing, Josephus Problem
- Clue words: "reverse", "merge", "cycle", "middle", "reorder"

## Templates

<details>
<summary>Reverse K Group</summary>

```python
class Solution:
        def reverseKGroup(self, head: Optional[ListNode], k: int) -> Optional[ListNode]:

            def rev(head):
                prev = None
                while head:
                    nxt = head.next
                    head.next = prev
                    prev = head
                    head = nxt
                return prev

            def fetchkthNode(head):
                for _ in range(1,k):
                    if not head:
                        return None
                    head = head.next
                return head

            current = head
            prevLLTail = None
            while current:
                # current(head) --> kthNode
                kthNode = fetchkthNode(current)
                if not kthNode:
                    if current:
                        prevLLTail.next = current
                    break
                    
                nxt = kthNode.next
                kthNode.next = None

                 # kthNode -- current(head)
                rev(current)
                if current == head:# reversed
                    head = kthNode
                else:
                    prevLLTail.next = kthNode
                prevLLTail = current
                current = nxt
            
            return head            
```
</details>

<details>
<summary>Flatten Multilevel DLL (Recursion)</summary>

```python
class Solution:
    def flatten(self, head: 'Optional[Node]') -> 'Optional[Node]':

        current = head
        #iterate
        while current:
            nxt = current.next
            #if child exists - attach to next
            if current.child:
                # child will become normal node now
                # think a->c
                #      b
                # attach b to a the continue
                child = self.flatten(current.child)
                current.next = child
                child.prev = current
                while child.next:
                    child = child.next
                child.next = nxt #attach next at end
                if nxt:
                    nxt.prev = child
            
            current.child = None
            #continue iterate again
            current = nxt
        return head     #return normal head  
```
</details>

<details>
<summary>LRU Cache (DLL + HashMap)</summary>

```python
class Node:
    def __init__(self, key: int = 0, val: int = 0):
        self.key = key
        self.val = val
        self.prev = None
        self.next = None


class LRUCache:
    def __init__(self, capacity: int):
        self.capacity = capacity
        self.cache = {} #stores direct node

        # Dummy nodes remove edge-case checks for empty/head/tail handling
        self.head = Node()  # Most recently used is head.next
        self.tail = Node()  # Least recently used is tail.prev
        self.head.next = self.tail
        self.tail.prev = self.head

    # delete in DLL
    def _remove(self, node: Node) -> None:
        prev_node = node.prev
        next_node = node.next
        prev_node.next = next_node
        next_node.prev = prev_node

    # insert in DLL
    def _insert_after_head(self, node: Node) -> None:
        node.next = self.head.next
        node.prev = self.head
        self.head.next.prev = node
        self.head.next = node

    def get(self, key: int) -> int:
        if key not in self.cache:
            return -1
        node = self.cache[key]
        self._remove(node) # delete old node
        self._insert_after_head(node)  # mark as MRU
        return node.val

    def put(self, key: int, value: int) -> None:
        if key in self.cache:
            node = self.cache[key]
            node.val = value
            self._remove(node)
            self._insert_after_head(node)  # updated key becomes MRU
            return

        if len(self.cache) == self.capacity:
            lru = self.tail.prev
            self._remove(lru)
            del self.cache[lru.key]

        new_node = Node(key, value)
        self.cache[key] = new_node
        self._insert_after_head(new_node)
```
</details>

## Key Problems
| # | Problem | Key Trick |
|---|---------|-----------|
| 1 | Reverse Linked List | prev/curr/next pointers |
| 2 | Merge Two Sorted Lists | Dummy node + compare |
| 3 | Linked List Cycle | Slow & fast pointers |
| 4 | Reorder List | Find mid → reverse → merge |
| 5 | Remove Nth Node From End | Two pointers, n gap |
| 6 | Add Two Numbers | Carry + dummy node |
| 7 | LRU Cache | HashMap + doubly linked list |

## My Notes
<!-- Add your own observations, mistakes, and learnings below -->
- head pointer very important and always special case