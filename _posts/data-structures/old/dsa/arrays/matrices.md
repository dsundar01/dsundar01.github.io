# Matrices

## Technique
- 2D grid traversal
- <u>**Matrix rotation / transformation**</u>
- <u>**Think in terms of what row/col each cell maps to after transformation E.g 90° clockwise: (r, c) → (c, n-1-r)**</u>
- Search in sorted matrix
- Clue words: "grid", "matrix", "rotate", "spiral", "island"

## Templates


### Spiral Order
```python
from typing import List

class Solution:
    def spiralOrder(self, matrix: List[List[int]]) -> List[int]:
        if not matrix:
            return []

        result = []
        #start from 4 ends
        rowStart, rowEnd = 0, len(matrix) - 1
        colStart, colEnd = 0, len(matrix[0]) - 1

        while rowStart <= rowEnd and colStart <= colEnd:
            # Traverse Right till end of column
            for col in range(colStart, colEnd + 1):
                result.append(matrix[rowStart][col])
            rowStart += 1 #avoid duplicate collection in corners & take right

            # Traverse Down till end of row
            for row in range(rowStart, rowEnd + 1):
                result.append(matrix[row][colEnd])
            colEnd -= 1 # take left

            # Traverse Left till start of column
            if rowStart <= rowEnd:
                for col in range(colEnd, colStart - 1, -1):
                    result.append(matrix[rowEnd][col])
                rowEnd -= 1 #take up

            # Traverse Up till start of row
            if colStart <= colEnd:
                for row in range(rowEnd, rowStart - 1, -1):
                    result.append(matrix[row][colStart])
                colStart += 1 #take right

        return result

```

### Rotate Matrix 90° Clockwise
```python
# Step 1: Transpose → rows become columns (swap across diagonal)
# Step 2: Reverse each row → completes 90° clockwise rotation
n = len(matrix)
for i in range(n):
    for j in range(i, n):  # j starts at i to avoid swapping back
        matrix[i][j], matrix[j][i] = matrix[j][i], matrix[i][j]
for row in matrix:
    row.reverse()
```

### Search Sorted Matrix
```python
# Start from top-right corner
# if value > target → move left (smaller values)
# if value < target → move down (larger values)
r, c = 0, len(matrix[0]) - 1
while r < len(matrix) and c >= 0:
    if matrix[r][c] == target: return True
    elif matrix[r][c] > target: c -= 1  # eliminate current column
    else: r += 1  # eliminate current row
return False
```

## Key Problems
| Problem | Approach |
|---------|----------|
| Number of Islands | DFS/BFS on grid |
| Spiral Matrix | Layer by layer traversal |
| Rotate Image | Transpose + reverse |
| Set Matrix Zeroes | Use first row/col as markers |
| Search a 2D Matrix II | Start top-right corner |

## My Notes
For matrix transformation problems, here's the approach:

**1. Identify the transformation type:**
- **Rotation** → Transpose + Reverse (don't try to swap elements directly)
- **Spiral** → Use 4 boundary pointers (rowStart, rowEnd, colStart, colEnd), shrink inward
- **In-place modification** (Set Zeroes, Game of Life) → Use markers (first row/col or bit encoding) to avoid overwriting data you still need

**2. Key mental model:**
- Think in terms of **what row/col each cell maps to** after transformation
  - 90° clockwise: `(r, c) → (c, n-1-r)`
  - 90° counter-clockwise: `(r, c) → (n-1-c, r)`
  - 180°: `(r, c) → (n-1-r, n-1-c)`
- If direct mapping is complex, **decompose into simpler steps** (transpose + reverse)

**3. Direction vs Pointer:**
- **Boundary pointers** for traversal problems (spiral, layer-by-layer) — shrink boundaries after each pass
- **Direction arrays** `[(0,1),(1,0),(0,-1),(-1,0)]` for graph-like traversal (DFS/BFS on grid)
- **Diagonal traversal** — group by `r+c` (same diagonal) or `r-c` (anti-diagonal)

**4. General checklist:**
- Can I do it **in-place**? → Swap/reverse tricks
- Am I **searching**? → Start from a corner that gives elimination (top-right or bottom-left)
- Am I **traversing**? → Boundary pointers or direction array
- Am I **transforming**? → Find the mapping formula, decompose into steps

The core idea: **don't think cell-by-cell**, think about what operation maps the entire structure (transpose, reverse, rotate boundaries).