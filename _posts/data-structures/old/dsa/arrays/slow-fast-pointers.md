# Slow & Fast Pointers

## Technique
- In a circular track, <u>**30Kmph and 60Kmph cars will meet definitely at some point**</u>
- Clue words: "cycle", "circular", "middle node", "happy number"
- s = f = head (2nd Mid); s,f = head, head.next (1st Mid)
- 2 Pointer(winner)

## Template

### Find Middle of Linked List
```python
class Solution:
    def middleNode(self, head):
        s = f = head
        while f and f.next:
            f = f.next.next
            s = s.next
        return s
        
```

### Remove Loop
```python
class Solution:
    #Function to remove a loop in the linked list.
    def removeLoop(self, head):
        
        slow = fast = head
        # find cycle
        while fast and fast.next:
            slow = slow.next
            fast = fast.next.next
            if slow == fast:
                break
        else:
            return
        # find 1st node
        slow = head
        while slow != fast:
            slow = slow.next
            fast = fast.next
        # find tail of cycle (node pointing back to cycle start)
        ptr =slow
        while ptr.next != slow:
            ptr = ptr.next
        ptr.next = None
               
```

## Key Problems
| Problem | Approach |
|---------|----------|
| Linked List Cycle | Fast catches slow → cycle |
| Linked List Cycle II | Reset slow to head, move both by 1 |
| Find Middle | Fast reaches end → slow at middle |
| Happy Number | Treat as cycle detection |
| Palindrome Linked List | Find middle → reverse second half → compare |

## My Notes

[Slow & Fast Pointer](/assets/slow-fast-proof.png ':ignore')
- both s and f started at head; but have equal distance to meeting point 
- but fast ran extra round - kc : extra rounds
https://www.notion.so/Note-2-2deab1fe3aaa8041bb43e0cbfbf7a065#2deab1fe3aaa803e8ca3ddc3a0cbd8d7
https://www.notion.so/2deab1fe3aaa80d08d91fca737c7a8f7?v=2deab1fe3aaa80bba5be000c76e493f5&p=2deab1fe3aaa80f9a073e4fb5c2965c1&pm=s
https://www.notion.so/2deab1fe3aaa80d08d91fca737c7a8f7?v=2deab1fe3aaa80bba5be000c76e493f5&p=2deab1fe3aaa801398d8c3bc350c2f8a&pm=s
