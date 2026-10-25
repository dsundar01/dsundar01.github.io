# Binary Search Tree (BST)

## When to Use
- Sorted data + fast search/insert/delete
- Finding kth smallest/largest
- Range queries
- Clue: "sorted order", "successor", "predecessor"

## Key Property
> For every node: **left subtree < node < right subtree**
> Inorder traversal of BST = sorted order

## Template

### Search
```java
TreeNode search(TreeNode root, int val) {
    if (root == null || root.val == val) return root;
    return val < root.val ? search(root.left, val) : search(root.right, val);
}
```

### Insert
```java
TreeNode insert(TreeNode root, int val) {
    if (root == null) return new TreeNode(val);
    if (val < root.val) root.left = insert(root.left, val);
    else root.right = insert(root.right, val);
    return root;
}
```

### Delete
```java
TreeNode delete(TreeNode root, int key) {
    if (root == null) return null;
    if (key < root.val) root.left = delete(root.left, key);
    else if (key > root.val) root.right = delete(root.right, key);
    else {
        // found node to delete
        if (root.left == null) return root.right;
        if (root.right == null) return root.left;
        // two children: replace with inorder successor
        TreeNode successor = findMin(root.right);
        root.val = successor.val;
        root.right = delete(root.right, successor.val);
    }
    return root;
}
```

### Validate BST

<details>
<summary>Validate BST (Inorder)</summary>

```python
class Solution:
    def isValidBST(self, root: Optional[TreeNode]) -> bool:

        prev = None
        def f(root):
            nonlocal prev
            if not root:
                return True
            if not f(root.left):#got null
                return False 
            if prev and prev.val >= root.val:
                return False
            prev = root
            if not f(root.right):  # will get null
                return False 
            return True
        return f(root)
```

</details>

## Complexity (Balanced BST)
- **Search / Insert / Delete:** O(log n)
- **Worst case (skewed):** O(n)
- **Space:** O(h) for recursion

## Edge Cases
- Empty tree
- Duplicate values (decide: left or right or skip)
- Deleting root
- Skewed tree (all left or all right)

## Problems

| # | Problem | Difficulty | Key Trick |
|---|---|---|---|
| 1 | Search in BST | Easy | Compare and go left/right |
| 2 | Kth Smallest Element in BST | Medium | Inorder traversal, count k |
| 3 | Validate BST | Medium | Pass valid range (min, max) |
| 4 | Convert Sorted Array to BST | Easy | Pick mid as root, recurse |
| 5 | Delete Node in BST | Medium | Handle 3 cases (0, 1, 2 children) |

## My Notes
<!-- Add your own observations, mistakes, and learnings below -->

