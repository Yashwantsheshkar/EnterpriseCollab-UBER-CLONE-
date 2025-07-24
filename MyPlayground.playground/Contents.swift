import Foundation


actor Node {
    let value: String
    private(set) var links: [Node] = []
    private(set) weak var parent: Node?
    private var ancestorLocked: Int = 0
    private var descendantLocked: Int = 0
    private var uid: Int = 0
    private var isLocked: Bool = false
    
    init(value: String, parent: Node? = nil) {
        self.value = value
        self.parent = parent
    }
    
    
    func getIsLocked() -> Bool {
        return isLocked
    }
    
    func getUID() -> Int {
        return uid
    }
    
    func getAncestorLocked() -> Int {
        return ancestorLocked
    }
    
    func getDescendantLocked() -> Int {
        return descendantLocked
    }
    
    func getParent() -> Node? {
        return parent
    }
    
    func getLinks() -> [Node] {
        return links
    }
    
    
    func setLocked(locked: Bool, uid: Int) {
        self.isLocked = locked
        if locked {
            self.uid = uid
        }
    }
    
    func incrementAncestorLocked() {
        ancestorLocked += 1
    }
    
    func decrementAncestorLocked() {
        ancestorLocked -= 1
    }
    
    func incrementDescendantLocked() {
        descendantLocked += 1
    }
    
    func decrementDescendantLocked() {
        descendantLocked -= 1
    }
    
    func addLinks(_ nodeValues: [String]) {
        for value in nodeValues {
            links.append(Node(value: value, parent: self))
        }
    }
}



let mockInput = """
7 2 5
World
Asia
Africa
China
India
SouthAfrica
Egypt
1 China 9
1 India 9
3 Asia 9
2 India 9
2 Asia 9
"""

var inputLines = mockInput.split(separator: "\n").map { String($0) }
@MainActor func readLine() -> String? {
    return inputLines.isEmpty ? nil : inputLines.removeFirst()
}



Task {
    await runTreeLockingSystem()
}

// MARK: - Tree Class
actor Tree {
    private let root: Node
    private var valueToNode: [String: Node] = [:]
    
    init(root: Node) {
        self.root = root
    }
    
    // MARK: - Tree Building
    static func buildTree(root: Node, m: Int, nodeValues: [String]) async -> Node {
        var queue: [Node] = [root]
        var startIndex = 1
        
        while !queue.isEmpty {
            let currentNode = queue.removeFirst()
            
            if startIndex >= nodeValues.count { continue }
            
            var temp: [String] = []
            for i in startIndex..<min(startIndex + m, nodeValues.count) {
                temp.append(nodeValues[i])
            }
            
            await currentNode.addLinks(temp)
            startIndex += m
            
            let links = await currentNode.getLinks()
            queue.append(contentsOf: links)
        }
        
        return root
    }
    
    // MARK: - Fill Value to Node Map
    func fillValueToNode(_ node: Node) async {
        valueToNode[node.value] = node
        let links = await node.getLinks()
        for child in links {
            await fillValueToNode(child)
        }
    }
    
    // MARK: - Helper Functions
    private func informDescendants(_ node: Node, _ delta: Int) async {
        let links = await node.getLinks()
        for child in links {
            if delta > 0 {
                await child.incrementAncestorLocked()
            } else {
                await child.decrementAncestorLocked()
            }
            await informDescendants(child, delta)
        }
    }
    
    private func verifyDescendants(_ node: Node, _ id: Int, _ lockedNodes: inout [Node]) async -> Bool {
        let isLocked = await node.getIsLocked()
        if isLocked {
            let nodeUID = await node.getUID()
            if nodeUID != id {
                return false
            }
            lockedNodes.append(node)
        }
        
        let descendantLocked = await node.getDescendantLocked()
        if descendantLocked == 0 {
            return true
        }
        
        let links = await node.getLinks()
        for child in links {
            if !(await verifyDescendants(child, id, &lockedNodes)) {
                return false
            }
        }
        return true
    }
    
    // MARK: - Main Operations
    func lock(value: String, id: Int) async -> Bool {
        guard let targetNode = valueToNode[value] else { return false }
        
        // Check if can lock
        let isLocked = await targetNode.getIsLocked()
        let ancestorLocked = await targetNode.getAncestorLocked()
        let descendantLocked = await targetNode.getDescendantLocked()
        
        if isLocked || ancestorLocked != 0 || descendantLocked != 0 {
            return false
        }
        
        // Update all ancestors
        var current = await targetNode.getParent()
        while let currentNode = current {
            await currentNode.incrementDescendantLocked()
            current = await currentNode.getParent()
        }
        
        // Inform all descendants
        await informDescendants(targetNode, 1)
        
        // Lock the node
        await targetNode.setLocked(locked: true, uid: id)
        
        return true
    }
    
    func unlock(value: String, id: Int) async -> Bool {
        guard let targetNode = valueToNode[value] else { return false }
        
        let isLocked = await targetNode.getIsLocked()
        let nodeUID = await targetNode.getUID()
        
        if !isLocked || nodeUID != id {
            return false
        }
        
        // Update all ancestors
        var current = await targetNode.getParent()
        while let currentNode = current {
            await currentNode.decrementDescendantLocked()
            current = await currentNode.getParent()
        }
        
        // Inform all descendants
        await informDescendants(targetNode, -1)
        
        // Unlock the node
        await targetNode.setLocked(locked: false, uid: 0)
        
        return true
    }
    
    func upgrade(value: String, id: Int) async -> Bool {
        guard let targetNode = valueToNode[value] else { return false }
        
        let isLocked = await targetNode.getIsLocked()
        let ancestorLocked = await targetNode.getAncestorLocked()
        let descendantLocked = await targetNode.getDescendantLocked()
        
        if isLocked || ancestorLocked != 0 || descendantLocked == 0 {
            return false
        }
        
        var lockedNodes: [Node] = []
        if !(await verifyDescendants(targetNode, id, &lockedNodes)) {
            return false
        }
        
        // Unlock all descendants
        for node in lockedNodes {
            _ = await unlock(value: node.value, id: id)
        }
        
        // Lock the target node
        return await lock(value: value, id: id)
    }
}


func runTreeLockingSystem() async {
    // Read input
    guard let firstLine = await readLine()?.split(separator: " ").compactMap({ Int($0) }),
          firstLine.count == 3 else {
        print("Invalid input")
        return
    }
        
        let n = firstLine[0]
        let m = firstLine[1]
        let q = firstLine[2]
        
        var nodeValues: [String] = []
        for _ in 0..<n {
            if let value = await readLine() {
                nodeValues.append(value)
            }
        }
        
        // Build tree
        let root = Node(value: nodeValues[0])
        _ = await Tree.buildTree(root: root, m: m, nodeValues: nodeValues)
        
        let tree = Tree(root: root)
        await tree.fillValueToNode(root)
        
        // Process queries
        for _ in 0..<q {
            guard let query = await readLine()?.split(separator: " "),
                  query.count == 3,
                  let operation = Int(query[0]),
                  let uid = Int(query[2]) else {
                continue
            }
            
            let nodeName = String(query[1])
            
            switch operation {
            case 1:
                let result = await tree.lock(value: nodeName, id: uid)
                print(result ? "true" : "false")
            case 2:
                let result = await tree.unlock(value: nodeName, id: uid)
                print(result ? "true" : "false")
            case 3:
                let result = await tree.upgrade(value: nodeName, id: uid)
                print(result ? "true" : "false")
            default:
                break
            }
        }
    }



class NodeWithLock {
    let value: String
    private var links: [NodeWithLock] = []
    private weak var parent: NodeWithLock?
    private var ancestorLocked: Int = 0
    private var descendantLocked: Int = 0
    private var uid: Int = 0
    private var isLocked: Bool = false
    private let lock = NSLock()
    
    init(value: String, parent: NodeWithLock? = nil) {
        self.value = value
        self.parent = parent
    }
    
    func withLock<T>(_ work: () throws -> T) rethrows -> T {
        lock.lock()
        defer { lock.unlock() }
        return try work()
    }
    
    func addLinks(_ nodeValues: [String]) {
        withLock {
            for value in nodeValues {
                links.append(NodeWithLock(value: value, parent: self))
            }
        }
    }
    
    func getLinks() -> [NodeWithLock] {
        return withLock { links }
    }
    
    func getParent() -> NodeWithLock? {
        return parent
    }
    
    func canLock() -> Bool {
        return withLock {
            !isLocked && ancestorLocked == 0 && descendantLocked == 0
        }
    }
    
    func setLocked(locked: Bool, uid: Int) {
        withLock {
            self.isLocked = locked
            if locked {
                self.uid = uid
            }
        }
    }
    
    func incrementAncestorLocked() {
        withLock {
            ancestorLocked += 1
        }
    }
    
    func decrementAncestorLocked() {
        withLock {
            ancestorLocked -= 1
        }
    }
    
    func incrementDescendantLocked() {
        withLock {
            descendantLocked += 1
        }
    }
    
    func decrementDescendantLocked() {
        withLock {
            descendantLocked -= 1
        }
    }
    
    func checkLockStatus() -> (isLocked: Bool, uid: Int) {
        return withLock {
            (isLocked, uid)
        }
    }
    
    func checkDescendantLocked() -> Int {
        return withLock { descendantLocked }
    }
    
    func checkAncestorLocked() -> Int {
        return withLock { ancestorLocked }
    }
}
