//
//  Node.swift
//  DataBaseTreeDemostration
//
//  Created by  Macbook on 22.09.2020.
//  Copyright © 2020 Golovelv Maxim. All rights reserved.
//

import Foundation

class Node<Element>: NSCopying {
    
    var id: String
    var value: Element
    var children = [Node]()
    weak var parent: Node?
    var height: Int = 0
    var isDeleted = false
    
    init(value: Element) {
        self.id = UUID().uuidString
        self.value = value
    }
    /// Add child node to parent node
    /// - parameter child: Child Node
    func add(child: Node) {
        children.append(child)
        child.parent = self
        child.height = height + 1
        if isDeleted {
            child.remove()
        }
    }
    
    /// Remove current node and it's children
    func remove() {
        isDeleted = true
        
        for child in children {
            child.remove()
        }
    }
    
    /// Find and remove first node that is equal to given node
    /// - parameter node: Given Node
    func remove(node: Node) {
        if let result = search(element: node) {
            result.isDeleted = true
        }
    }
    func copy(with zone: NSZone? = nil) -> Any {
        let node = Node(value: self.value)
        node.parent = parent
        node.id = id
        return node
    }
    /// Create and return a copy of a current node and all of it's children. Parent references remain unchanged
    func deepCopy() -> Node<Element> {
        let node = Node(value: self.value)
        node.parent = parent
        node.id = id
        node.value = value
        node.height = height
        node.isDeleted = isDeleted
        
        for child in children {
            node.children.append(child.deepCopy())
        }
        
        return node
    }
    /// Create and return an array of node and all of it's children in order
    func getAllElements() -> [Node<Element>] {
        if children.isEmpty {
            return [self]
        }
        
        var result = [self]
        
        for child in children {
            result.append(contentsOf: child.getAllElements())
        }
        
        return result
    }
    
    /// Find and return first node that is equal to given node
    /// - parameter node: Given Node
    func search(element: Node) -> Node? {

        if element == self {
            return self
        }

        for child in children {
            if let found = child.search(element: element) {
                return found
            }
        }

        return nil
    }
    
    /// Update height of a given node and all of it's children
    /// - parameter node: Given Node
    func updateHeight(node: Node, value: Int) {
        
        node.height = value
        
        for child in node.children {
            updateHeight(node: child, value: value + 1)
        }
    }
    
    /// Merge single node without children into current node
    /// - parameter node: Single Node
    func merge(node: Node) -> Node<Element>? {
        
        if node == self {
            return self
        } else if node.parent == self {
            if children.contains(node) {
                return self
            }
            add(child: node)
            updateHeight(node: node, value: node.height)
            return self
        } else if self.parent == node {
            node.add(child: self)
            updateHeight(node: self, value: self.height)
            return node
        } else if !children.isEmpty {
            
            for index in 0...(children.count - 1) {
                let child = children[index]
                let result = child.merge(node: node)
                if result == child {
                    return self
                }
                if result == nil, index == children.count - 1 {
                    return nil
                }
            }
            return self
        }
        
        return nil
    }
    
    /// Merge given node into current node
    /// - parameter node: Given Node
    func merge(tree: Node) {
        
        if let match = search(element: tree) {
            match.value = tree.value
            if tree.isDeleted {
                match.remove()
            }
            if match.isDeleted {
                tree.remove()
            }
        } else if let parent = tree.parent, let selfParent = search(element: parent){
            let copy = tree.deepCopy()
            copy.height = selfParent.height
            selfParent.add(child: copy)
        }
        
        for child in tree.children {
            merge(tree: child)
        }
    }
}

extension Node: Equatable {
    static func == (lhs: Node<Element>, rhs: Node<Element>) -> Bool {
        return lhs.id == rhs.id
    }
}


extension Node: CustomStringConvertible {

    var description: String {
    var text = "\(value)"
    
    if !children.isEmpty {
      text += " {" + children.map { $0.description }.joined(separator: ", ") + "} "
    }
    return text
  }
}

extension Node where Element: Equatable {
    
    /// Find and return the first node witch value is equal to the given node
    /// - parameter node: Given Node
    func search(value: Element) -> Node? {

        if value == self.value {
          return self
        }

        for child in children {
          if let found = child.search(value: value) {
            return found
          }
        }

        return nil
    }
    
}
