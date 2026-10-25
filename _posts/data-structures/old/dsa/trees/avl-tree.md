# AVL Tree

## When to Use
- Self-balancing BST
- Guaranteed O(log n) search, insert, delete
- When frequent lookups and balanced height required

## Key Concepts
- **Balance factor** = height(left) - height(right), must be -1, 0, or 1
- If unbalanced after insert/delete, perform **rotations**

## Rotations

### Right Rotation (Left-Left case)
```java
Node rightRotate(Node y) {
    Node x = y.left;
    Node T2 = x.right;
    x.right = y;
    y.left = T2;
    y.height = 1 + Math.max(height(y.left), height(y.right));
    x.height = 1 + Math.max(height(x.left), height(x.right));
    return x;
}
```

### Left Rotation (Right-Right case)
```java
Node leftRotate(Node x) {
    Node y = x.right;
    Node T2 = y.left;
    y.left = x;
    x.right = T2;
    x.height = 1 + Math.max(height(x.left), height(x.right));
    y.height = 1 + Math.max(height(y.left), height(y.right));
    return y;
}
```

## Insert with Balancing
```java
Node insert(Node node, int key) {
    if (node == null) return new Node(key);
    if (key < node.key) node.left = insert(node.left, key);
    else if (key > node.key) node.right = insert(node.right, key);
    else return node;

    node.height = 1 + Math.max(height(node.left), height(node.right));
    int balance = getBalance(node);

    // Left Left
    if (balance > 1 && key < node.left.key) return rightRotate(node);
    // Right Right
    if (balance < -1 && key > node.right.key) return leftRotate(node);
    // Left Right
    if (balance > 1 && key > node.left.key) {
        node.left = leftRotate(node.left);
        return rightRotate(node);
    }
    // Right Left
    if (balance < -1 && key < node.right.key) {
        node.right = rightRotate(node.right);
        return leftRotate(node);
    }
    return node;
}
```

## Summary
| Case | Rotation |
|------|----------|
| Left-Left | Right rotate |
| Right-Right | Left rotate |
| Left-Right | Left rotate left child, then right rotate |
| Right-Left | Right rotate right child, then left rotate |
