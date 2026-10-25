# Trie

## When to Use
- Prefix matching / autocomplete
- Word search in dictionary
- Clue words: "prefix", "dictionary", "word search", "autocomplete"

## Template

<details>
<summary>Trie (Insert & Search)</summary>

```python
class TrieNode:
    def __init__(self):
        self.children = {}
        self.is_end = False


class Trie:
    def __init__(self):
        self.root = TrieNode()

    # Insert word
    def insert(self, word: str) -> None:
        node = self.root
        for ch in word:
            # Insert character if doesn't exist
            if ch not in node.children:
                node.children[ch] = TrieNode()
            node = node.children[ch]
        node.is_end = True

    # Search for a word
    def search(self, word: str) -> bool:
        node = self.root
        for ch in word:
            # if single character doesn't exist
            if ch not in node.children:
                return False
            node = node.children[ch]
        return node.is_end
```

</details>

<details>
<summary>Trie Delete</summary>

```python
    # Delete word
    def delete(self, word: str) -> bool:
        def _delete(node, word, depth):
            if not node:
                return False

            if depth == len(word):
                if not node.is_end:
                    return False  # word not found
                node.is_end = False
                # information to delete child or not
                return len(node.children) == 0  # prune if no children

            ch = word[depth]
            # character doesn't exist
            if ch not in node.children:
                return False

            should_delete_child = _delete(node.children[ch], word, depth + 1)

            if should_delete_child:
                del node.children[ch]
                # send information to delete child or not
                return not node.is_end and len(node.children) == 0

            return False

        return _delete(self.root, word, 0)
```

</details>

<details>
<summary>Autocomplete & Replace</summary>

```python
    # Autocomplete suggestions
    def autocomplete(self, prefix: str) -> list[str]:
        #dfs
        def _dfs(node, path, results):
            if node.is_end:
                results.append(path)
            for ch, child in node.children.items():
                _dfs(child, path + ch, results)

        node = self.root
        # 1st check prefix exists, then run dfs
        for ch in prefix:
            if ch not in node.children:
                return []  # no suggestions
            node = node.children[ch]

        results = []
        # call internal function
        _dfs(node, prefix, results)
        return results

    # Replace old_word with new_word
    def replace(self, old_word: str, new_word: str) -> None:
        if self.search(old_word):
            self.delete(old_word)
            self.insert(new_word)
```

</details>

## Key Problems
| Problem | Approach |
|---------|----------|
| Implement Trie | Array of 26 children per node |
| Word Search II | Trie + grid backtracking |
| Design Search Autocomplete | Trie + frequency tracking |
| Replace Words | Insert roots, match prefixes |
| Longest Word in Dictionary | Trie + BFS/DFS |
