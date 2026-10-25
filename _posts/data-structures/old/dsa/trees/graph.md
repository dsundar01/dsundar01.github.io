# Graph

## When to Use

| Problem type | Approach |
|---|---|
| Paths / shortest path | Dijkstra, Bellman-Ford, Floyd-Warshall |
| Structure / connectivity | DFS / BFS |
| Grouping / components | DSU |
| Ordering / dependencies | Topological Sort |
| Network strength / capacity | MST / Max Flow |

> In any graph, shortest path uses at most `V − 1` edges (more implies a cycle).

| Algorithm | Graph representation | Why |
|---|---|---|
| BFS / DFS | Adjacency list | Neighbor traversal |
| Dijkstra | Adjacency list + heap | Pick best next node |
| Bellman-Ford | Edge list (u, v, w) | Relax all edges V−1 times |
| Kruskal | Edge list | Sort edges by weight |
| Prim | Adjacency list + heap | Grow MST from node |

- Clue words: "connected", "path", "network", "grid", "island"

## Representations
```python
 def createGraph(self, V, edges):
    graph = {i: set() for i in range(V)}
    for u, v in edges:
        graph[u].add(v)
        graph[v].add(u)
    return graph

        
    def createWeightGraph()->dict:
        graph = {i:[] for i in range(V)} 
        for u,v,w in edges:
            graph[u].append((v,w))
            graph[v].append((u,w))
        return graph
```

## Templates

<details>
<summary>DFS</summary>

```python
```

</details>

<details>
<summary>BFS</summary>

```python
from collections import deque
class Solution:
    # Sweeper
    def bfs(self, adj):
        
        q = deque([0])
        visited = set()
        visited.add(0)
        result = list()
        
        while q:
            curNode = q.popleft()
            result.append(curNode)
            # visited branches
            for b in adj[curNode]:
                if b not in visited:
                    visited.add(b)
                    q.append(b)
                    
        return result
```

</details>

<details>
<summary>DSU (Disjoint Set Union)</summary>

```python

class RankDSU:
    def __init__(self,n):
        self.parent = [i for i in range(n)]
        self.rank = [1] * n
        self.components = n
    
    def find(self, x) -> int:
        if x != self.parent[x]:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]

    def union(self, x, y) -> bool:
        pX, pY = self.parent[x], self.parent[y]
        if pX == pY:
            return False
        if self.rank[pX] > self.rank[pY]:
            self.parent[pY] = pX
        elif self.rank[pX] < self.rank[pY]:
            self.parent[pX] = pY
        else:
            self.parent[pY] = pX
            self.rank[pX] += 1
        self.components -= 1
        return True
```

</details>

<details>
<summary>Dijkstra's Shortest Path (BFS-PQ)</summary>

```python
import heapq

def dijkstra(edges, V, E, src):
    
    #form graph
    graph = {i:[] for i in range(V)}
    for u,v,w in edges:
        graph[u].append((v,w))
        graph[v].append((u,w))

    d = [2147483647] * V
    d[src] = 0
    pq = [(0,src)]#(wt, node)

    while pq:
        # u->v
        node = heapq.heappop(pq)
        u = node[1]#node u
        curW = node[0] #on top of u
        for v,w in graph[u]:#edge value, v
            newDist = curW + w
            #relax nieghbours
            if newDist < d[v]:
                d[v] = newDist
                heapq.heappush(pq,(newDist,v))#to handle after v
    
    return d
```

</details>

<details>
<summary>Bellman-Ford (-ve cycle)</summary>

```python
class Solution:
    def bellmanFord(self, V, edges, src):
        INF = 100000000
        dist = [INF] * V
        dist[src] = 0
        #shortest path needed to reach any node V-1
        for i in range(V):
	        #relax all edges -> all available path
            for u,v,w in edges:
		            #if we can reach 'v' cheaper -> update
                if dist[u] != INF and dist[v] > dist[u] + w:
                    dist[v] = dist[u]+w
                    
        for u,v,w in edges:
                if dist[u] != INF and dist[v] > dist[u] + w:
                    return [-1]
        
        return dist
```

</details>

<details>
<summary>Floyd Warshall</summary>

```python
# distance matrix
class Solution:
    def shortest_distance(self, matrix):
        
        INF = 1 << 32
        n = len(matrix)
        
        for i in range(n):
            for j in range(n):
                if matrix[i][j] == -1:
                    matrix[i][j] = INF
       
      # everytime we take a city consider as route
        for k in range(n):#take 1st city, keep it as intermediate for all 
            for u in range(n):
                for v in range(n):
		                # min(1->3, 1->2->3)
                    matrix[u][v] = min(matrix[u][v], matrix[u][k] + matrix[k][v])
        
        for i in range(n):
            for j in range(n):
                if matrix[i][j] == INF:
                    matrix[i][j] = -1
                    
        return matrix
```

</details>

<details>
<summary>Prims - MST (BFS)</summary>

```python
    # smallest graph with smallest weight with all node
    def spanningTree(self, V, edges):
        
        self.V, self.edges = V, edges
        graph = self.createWeightedGraph()
        
        visited = set()
        #“There is a candidate edge of cost weight that can connect this node to the current MST.”
        pq = [(0,0)]
        total = 0
        
        while pq:
            #pick smallest weight
            W, u = heapq.heappop(pq)
            #already visited means,we have edge reaching it
            if u in visited:# once node is chosen, don't chose again
                continue
            total += W
            visited.add(u)
            for v, wt in graph[u]:
            #do not schedule/push an edge to a node already in MST.
                if v not in visited:#don't schedule duplicate
                    # add the next node
                    heapq.heappush(pq, (wt, v))
                    
        if len(visited) != V:
            return -1
        
        return total
                
```

</details>

<details>
<summary>Kruskal - MST (DSU)</summary>

```python
class Solution:
    def spanningTree(self, V, edges):
        parent = [i for i in range(V)]
        rank = [0] * V
        
        def find(x):
            if x == parent[x]:
                return x
            parent[x] = find(parent[x])
            return parent[x]
        
        def union(x, y):
            x, y = find(x), find(y)
            if x == y: return False
            if rank[x] > rank[y]:
                parent[y] = x
            elif rank[y] > rank[x]:
                parent[x] = y
            else:
                parent[y] = x
                rank[x]+=1
            return True
                
        edges.sort(key=lambda x: x[2])
        visited, total = set(), 0
        
        for u,v,w in edges:
            # already reached node v
            if union(u, v):
                total += w
                
        return total
```

</details>

<details>
<summary>Find Cycle in Undirected Graph</summary>

```python
from collections import defaultdict
class Solution:      
    def dfs(self, currentNode, parentNode, graph, visited):
        
        if currentNode in visited:
            return False
            
        visited.add(currentNode)
        for neighbour in graph[currentNode]:
            # if neighbour is visited but not parent
            if neighbour in visited and neighbour != parentNode:
                return True
            if self.dfs(neighbour, currentNode, graph,visited):
                return True
            
	def isCycle(self, V, edges):
	    
	    #form graph
	    graph = self.createGraph(V, edges)
	    visited = set()
	    #run dfs to check
	    for i in range(V):
	        if self.dfs(i,-1,graph,visited):
	            return True
	    return False
```

</details>

<details>
<summary>Find Cycle in Directed Graph</summary>

```python
from collections import defaultdict
class Solution:  
    def dfsWithBT(self, currentNode, pathArray,visited):
        
        if currentNode in visited:
            return False
            
        visited.add(currentNode)
        pathArray.append(currentNode)
        for neighbour in self.graph[currentNode]:
            if neighbour in pathArray:
                return True
            if self.dfsWithBT(neighbour, pathArray, visited):
                return True
        pathArray.pop()
            
    def isCyclic(self, V, edges):
        
        self.V, self.edges = V, edges
        # create graph util
        self.graph = self.createGraph()
        pathArray, visited = list(), set()
        for i in range(V):
            # short circuit only when found cycle
            if self.dfsWithBT(i,pathArray,visited):
                return True
        return False
```

</details>

<details>
<summary>Topological Sort - DFS</summary>

```python
from collections import defaultdict

class Solution:
    def dfs(self, node, visited, pathVisited, stack):
        visited.add(node)
        pathVisited.add(node)

        for nei in self.graph[node]:
            if nei not in visited:
                if not self.dfs(nei, visited, pathVisited, stack):
                    return False
            elif nei in pathVisited:
                # cycle detected
                return False

        pathVisited.remove(node)
        stack.append(node)
        return True

    def topoSort(self, V, edges):
        self.graph = defaultdict(list)
        for u, v in edges:
            self.graph[u].append(v)

        visited = set()
        pathVisited = set()
        stack = []

        for i in range(V):
            if i not in visited:
                if not self.dfs(i, visited, pathVisited, stack):
                    return []   # ❌ no valid ordering

        return stack[::-1]

```

</details>

<details>
<summary>Kahn's Algorithm - BFS</summary>

```python
class Solution:
    def canFinish(self, N: int, pre: List[List[int]]) -> bool:
        
        inDegree = [0] * N
        graph = {i:set() for i in range(N)}
        for u, v in pre:
            inDegree[u] += 1 # u only dependent on v
            graph[v].add(u) #complete v and do u
        
        q = deque()
        for idx, val in enumerate(inDegree):
            if val == 0:
                q.append(idx)
        
        while q:
            cur = q.popleft()
            #since we removed cur, reduce 1 depedent on niegh
            for n in graph[cur]:
                inDegree[n] -= 1
                if inDegree[n] == 0:
                    q.append(n)
        
        return all(x == 0 for x in inDegree)
```

</details>

<details>
<summary>Number of Complete Components</summary>

```python
class Solution:
    def countCompleteComponents(self, n: int, edges: List[List[int]]) -> int:
        
        dsu = RankDSU(n)
        #plot graph in dsu
        for u, v in edges:
            dsu.union(u,v)

        # group Nodes
        nodeMap = defaultdict(set)
        for i in range(n):
            #attach each to super parent
            nodeMap[dsu.find(i)].add(i)

        #find number of edges in each component with given edges
        edgeMap = defaultdict(int)
        for u, v in edges:
            # add count to super parent
            root = dsu.find(u)
            edgeMap[root] += 1

        count = 0
        #count number of connected components
        for key, val in nodeMap.items():
            nodeOfNodes = len(val)
            required = nodeOfNodes * (nodeOfNodes-1)//2
            if edgeMap[key] == required:
                count += 1
        
        return count
```

</details>

<details>
<summary>Bipartite Graph</summary>

```python
from collections import deque

class Solution:
    def isBipartite(self, V, adj):
        colors = [-1] * V
        for i in range(V):
            if colors[i] == -1:
                if self.check(i, colors, adj):
                    return False
        return True

    def check(self, cur, colors, adj):
        q = deque([cur])
        colors[cur] = 0

        while q:
            current = q.popleft()
            color = colors[current]

            for next_node in adj[current]:
                # next current and adjacent color = 0 (break)
                if color == colors[next_node]:
                    return True
                if colors[next_node] == -1:
                    colors[next_node] = color ^ 1  # give opposite color for neighbours
                    q.append(next_node)
        return False
```

</details>

<details>
<summary>Strongly Connected Component (Kosaraju)</summary>

```python
class Solution:

    def toposort(self,u, adj, visited, stack):
        visited.add(u)
        for v in adj[u]:
            if v not in visited:
                self.toposort(v, adj, visited, stack)
        stack.append(u) #add parent after all
    
    def reverse(self, adj):
        n = len(adj)
        rg = [[] for _ in range(n)]
        for u in range(n):
            for v in adj[u]:
                rg[v].append(u)
        return rg
    
    def dfs(self, u, adj, visited):
        visited.add(u)
        for v in adj[u]:
            if v not in visited:
                self.dfs(v, adj, visited)
                
    def kosaraju(self, adj):
        
        n = len(adj)
        stack, visited = [], set()
        
        for i in range(n):
            if i not in visited:
                self.toposort(i, adj, visited, stack)
                
        rg = self.reverse(adj)
        visited.clear()
        count = 0
        while stack:
            u = stack.pop()
            if u not in visited:
                self.dfs(u, rg, visited)
                count += 1
        return count
```

</details>

<details>
<summary>Bridges (Tarjan)</summary>

```python
class Solution:
    
    def criticalConnections(self, n: int, connections: List[List[int]]) -> List[List[int]]:
        timer = 1
        def dfs(u, parent):
            nonlocal timer
            visited.add(u)
            tin[u] = low[u] = timer
            timer += 1
            
            for v in ug[u]:
                # case 1 -> v is parent
                if v == parent: continue
                # case 2 -> v is not visited
                if v not in visited:
                    #allow recursion to update low
                    dfs(v, u)
                    # get min from neighbour after v complete, so we know thingd
                    low[u] = min(low[u], low[v])
                  '''
                if v can reach u -> no bridge
                recursion of v doesn't use anything from u 
                  '''
                    if low[v] > tin[u]:
                        bridges.append([v,u])
                # case 3 not visited
                else: 
                    low[u] = min(low[u], tin[v])



        ug = [[] for _ in range(n)]
        for u, v in connections:
            ug[u].append(v)
            ug[v].append(u)
        visited, tin, low = set(),[0] * n, [0] * n
        
        bridges = []
        dfs(0,-1)
        return bridges
        
```

</details>

<details>
<summary>Articulation Point</summary>

```python
#User function Template for python3

import sys
sys.setrecursionlimit(10**6)

class Solution:
    def articulationPoints(self, V, adj):
        
        timer = 0
        
        def dfs(u, parent):
            nonlocal timer
            vis.add(u)
            tin[u] = low[u] = timer
            timer += 1
            
            children = 0
            
            for v in adj[u]:
                if v == parent:
                    continue
                
                if v not in vis:
                    dfs(v, u)
                    low[u] = min(low[u], low[v])
                    
                    # articulation condition (non-root)
                    if low[v] >= tin[u] and parent != -1:
                        mark.add(u)
                    
                    children += 1
                else:
                    # back-edge
                    low[u] = min(low[u], tin[v])
            
            # root articulation condition
            if parent == -1 and children > 1:
                mark.add(u)
        
        vis, mark = set(), set()
        tin, low = [0]*V, [0]*V
        
        for i in range(V):
            if i not in vis:
                dfs(i, -1)
        
        if not mark:
            return [-1]
        return sorted(mark)

```

</details>

<details>
<summary>Max Flow</summary>

```python
class FordFulkerson:
    def __init__(self, n):
        self.n = n
        self.res = [[0] * n for _ in range(n)]

    def add_edge(self, u, v, cap):
        self.res[u][v] += cap   # supports parallel edges

    def dfs(self, u, t, flow, visited):
        if u == t:
            return flow

        visited[u] = True

        for v in range(self.n):
            if not visited[v] and self.res[u][v] > 0:
                pushed = self.dfs(v, t, min(flow, self.res[u][v]), visited)
                if pushed > 0:
                    self.res[u][v] -= pushed
                    self.res[v][u] += pushed
                    return pushed

        return 0

    def max_flow(self, s, t):
        flow = 0
        INF = 10**9

        while True:
            visited = [False] * self.n
            pushed = self.dfs(s, t, INF, visited)
            if pushed == 0:
                break
            flow += pushed

        return flow
```

</details>

<details>
<summary>Min Cut</summary>

```python
# Min Cut = Max Flow (Max-Flow Min-Cut Theorem)
# After running max_flow, do BFS on residual graph from source
# Edges crossing from reachable to non-reachable = min cut edges

class MinCut(FordFulkerson):
    def min_cut(self, s, t):
        # first compute max flow (saturates residual graph)
        self.max_flow(s, t)

        # BFS on residual graph from source
        visited = [False] * self.n
        q = deque([s])
        visited[s] = True
        while q:
            u = q.popleft()
            for v in range(self.n):
                if not visited[v] and self.res[u][v] > 0:
                    visited[v] = True
                    q.append(v)

        # edges from reachable to non-reachable = min cut
        cut_edges = []
        for u in range(self.n):
            for v in range(self.n):
                if visited[u] and not visited[v] and self.res[v][u] > 0:
                    cut_edges.append((u, v))
        return cut_edges
```

</details>

## Key Problems
| Problem | Approach |
|---------|----------|
| Number of Islands | BFS/DFS on grid |
| Course Schedule | Topological sort / cycle detection |
| Clone Graph | BFS/DFS + HashMap |
| Network Delay Time | Dijkstra |
| Accounts Merge | Union-Find |

## My Notes

<details>
<summary>Post-DFS Patterns</summary>

```python
# Subtree Size
def dfs(u, p):
    size[u] = 1
    for v in adj[u]:
        if v != p:
            dfs(v, u)
            size[u] += size[v]

# Tree Height
def dfs(u, p):
    height[u] = 0
    for v in adj[u]:
        if v != p:
            dfs(v, u)
            height[u] = max(height[u], height[v] + 1)

# Tin/Low (Bridges & Articulation)
def dfs(u, p):
    nonlocal timer
    tin[u] = low[u] = timer
    timer += 1

    for v in adj[u]:
        if v == p: continue
        if not visited[v]:
            dfs(v, u)
            low[u] = min(low[u], low[v])   # ← post recursion
```

</details>

Graph - 227
AVL - 297