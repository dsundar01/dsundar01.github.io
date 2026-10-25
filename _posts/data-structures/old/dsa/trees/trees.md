# Trees

## When to Use

| Use BFS | Use DFS |
|---|---|
| Shortest path (unweighted) | Path existence |
| Level-order traversal | Preorder / Inorder / Postorder |
| Nearest neighbor | Detecting cycles |
| Minimum depth | Backtracking problems |

## Template

### BFS (Level Order)

<details>
<summary>Zigzag Level Order</summary>

```python
class Solution:
    def zigzagLevelOrder(self, root: Optional[TreeNode]) -> List[List[int]]:

        if not root:
            return []
        ans = []
        rev = False
        q = deque([root])
        while q:
            size = len(q)
            temp = []
            for _ in range(size):
                current = q.popleft()
                temp.append(current.val)
                if current.left:
                    q.append(current.left)
                if current.right:
                    q.append(current.right)
            if rev:
                ans.append(temp[::-1])
            else:
                ans.append(temp)
            rev = not rev
        return ans
```

</details>

### DFS (Recursive)

<details>
<summary>All Nodes Distance K</summary>

```python
class Solution(object):
    def distanceK(self, root, target, k):
        res = []
        def collectKthDown(current, k):
            if not current:
                return
            if k == 0:
                res.append(current.val)
                return
            collectKthDown(current.left,k-1)
            collectKthDown(current.right,k-1)
        
        def f(current, k):

            if not current:
                return -1

            if current == target:
                collectKthDown(current, k)
                return 0 #  target is 0 distance away
            
            dleft = f(current.left, k)
            if dleft != -1:
                if dleft+1 == k:
                    res.append(current.val)
                else:
                    # initially left = 0, it will make 2 steps[target->root,root->right]
                    # current.right is 2 distance way from target
                    collectKthDown(current.right,k-dleft-2)
                return dleft+1
            dright = f(current.right, k)
            if dright != -1:
                if dright+1 == k:
                    res.append(current.val)
                else:
                    collectKthDown(current.left, k-dright-2)
                return dright + 1
            return -1
        f(root, k)
        return res      
```

</details>

### Vertical Order Traversal of a Binary Tree

<details>
<summary>Vertical Order Traversal</summary>

```python
class Solution:
    def verticalTraversal(self, root: Optional[TreeNode]) -> List[List[int]]:

        '''
        vertical order - we want nodes on each vertical
        - multiple level in each vertical
        '''
        vmap = defaultdict(lambda:defaultdict(list))
        self.minCol = float('inf')
        self.maxCol = float('-inf')

        def f(current, r, c):
            if not current:
                return
            self.minCol = min(self.minCol, c)
            self.maxCol = max(self.maxCol, c)
            vmap[c][r].append(current.val)
            f(current.left, r+1,c-1)
            f(current.right, r+1, c+1)
        f(root, 0, 0)

        result = []
        for c in range(int(self.minCol), int(self.maxCol)+1):
            temp = []
            sortedRow = sorted(vmap[c].keys())
            for r in sortedRow:
                temp.extend(sorted(vmap[c][r]))
            result.append(temp)
        return result
```

</details>

## Traversal Order Cheat Sheet
- **Preorder** (Root-L-R): serialize tree, copy tree
- **Inorder** (L-Root-R): BST → sorted order
- **Postorder** (L-R-Root): delete tree, calculate height
- **Level order** (BFS): level-by-level problems, min depth

## Complexity
- **Time:** O(n) — visit every node
- **Space:** O(h) DFS, O(w) BFS (h = height, w = max width)

## Edge Cases
- Null root
- Single node
- Skewed tree (becomes linked list)
- Disconnected graph (need visited set + loop over all nodes)

## Problems

| # | Problem | Difficulty | Key Trick |
|---|---|---|---|
| 1 | Level Order Traversal | Medium | BFS with size trick |
| 2 | Max Depth of Binary Tree | Easy | DFS, return 1 + max(left, right) |
| 3 | Validate BST | Medium | Inorder must be sorted / pass min-max range |
| 4 | Lowest Common Ancestor | Medium | Postorder: if left && right → root is LCA |
| 5 | Serialize/Deserialize Tree | Hard | Preorder + queue for deserialize |

## My Notes
<!-- Add your own observations, mistakes, and learnings below -->

