---
title: "LinkedList Basics"
date: 2026-10-06 14:35:34 +05:30
categories: [Data Structures, Linked List]
tags: [neetcode]
---

## Reverse Nodes in k-Group

```python
class Solution:
    def reverseKGroup(self, head: ListNode | None, k: int) -> ListNode | None:

        def reverse(head):
            prev = None
            while head:
                next = head.next
                head.next = prev
                prev = head
                head = next
            return prev

        def findkth(head):
            for _ in range(1,k):
                if not head:
                    return None
                head = head.next
            return head
        
        current = head
        prevBlock = None

        while current:

            # c -- >
            kthnode = findkth(current)
            if not kthnode:
                if prevBlock:
                    prevBlock.next = current
                #other wise given LL less than k
                break

            next = kthnode.next
            kthnode.next = None #break

            #reverse k --> c
            reverse(current)
            if current == head:
                head = kthnode
            else:
                # attach new head
                prevBlock.next = kthnode
            
            prevBlock = current #new tail
            current = next
        return head
```

## 460. LFU Cache

```python
class Node:
    def __init__(self, k, v):
        self.key = k
        self.value = v
        self.count = 1
class LFUCache:

    def __init__(self, capacity: int):
        self.vmap = {}
        self.fmap = defaultdict(OrderedDict)
        self.min = 0
        self.size = capacity
    
    def increment(self, node):
        oldcount = node.count
        #remove node from oldcount
        del self.fmap[oldcount][node]
        #remove ll
        if not self.fmap[oldcount]:
            del self.fmap[oldcount]
            if oldcount == self.min:
                self.min += 1
        node.count += 1
        self.fmap[node.count][node] = None

    def get(self, key: int) -> int:
        if key not in self.vmap:
            return -1
        node = self.vmap[key]
        self.increment(node)
        return node.value
        

    def put(self, key: int, value: int) -> None:

        if key in self.vmap:
            node = self.vmap[key]
            node.value = value
            self.increment(node)
        else:
            if len(self.vmap) == self.size:
                lfu = self.fmap[self.min]
                lru,_ = lfu.popitem(last=False) #key=node, value = None
                del self.vmap[lru.key]
                if not lfu:
                    del lfu
            #insert new node
            newnode = Node(key, value)
            self.vmap[key] = newnode
            #python don't have OrderedSet
            self.fmap[1][newnode] = None
            self.min = 1
        
```
