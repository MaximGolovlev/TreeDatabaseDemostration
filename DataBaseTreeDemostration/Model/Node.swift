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
    /// Parameters
    func add(child: Node) {
        children.append(child)
        child.parent = self
        child.height = height + 1
    }
    
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
    
    func updateHeight(node: Node) {
        
        node.height += 1
        
        for child in node.children {
            updateHeight(node: child)
        }
    }
    
    func merge(node: Node) -> Node<Element> {
        
        let copy = node.copy() as! Node
        
        if copy == self {
            return self
        } else if copy.parent == self, !children.contains(copy) {
            add(child: copy)
            return self
        } else if self.parent == copy {
            copy.add(child: self)
            self.height -= 1
            updateHeight(node: self)
            return copy
        } else {
            for child in children {
                _ = child.merge(node: node)
            }
            return self
        }
    }
    
    func merge(tree: Node) {
        
        if let match = search(element: tree) {
            match.value = tree.value
            match.isDeleted = tree.isDeleted
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