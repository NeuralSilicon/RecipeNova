//SOURCE: https://www.raywenderlich.com/977854-data-structures-algorithms-in-swift

import Foundation

public class AVLNode<Element> where Element: Comparable {
    
    public var value: Element
    public var leftChild: AVLNode?
    public var rightChild: AVLNode?
    
    /*
     the height of a node is the longest distance from the current
     node to a leaf node.
     The hieght of left and right children of each node must differ by
     at most one.
     This is known as the balance factor
     */
    
    public var height = 0
    
    public init(value: Element){
        self.value = value
    }
    
    ///computes the difference of left and right child
    public var balancefactor: Int{
        return leftHeight - rightHeight
    }
    
    public var leftHeight: Int{
        return leftChild?.height ?? -1
    }
    
    public var rightHeight: Int{
        return rightChild?.height ?? -1
    }
    
    ///leaf
    var min: AVLNode{
        return leftChild?.min ?? self
    }
}


public struct AVLTree<Element: Comparable>{
    public private(set) var root: AVLNode<Element>?
    public init() {}
    
}


///Insertion and Remove
extension AVLTree{
    
    public var count:Int{
        var count = 0
        self.root?.traversePreOrder(visit: { (_) in
            count+=1
        })
        return count
    }
    
    public mutating func insert(_ value: Element){
        root = insert(from: root, value: value)
    }
    
    private func insert(from node: AVLNode<Element>?, value: Element) -> AVLNode<Element>?{
        guard let node = node else{
            return AVLNode(value: value)
        }
        if value < node.value{
            node.leftChild = insert(from: node.leftChild, value: value)
        }else{
            node.rightChild = insert(from: node.rightChild, value: value)
        }
        ///Instead of returning the node, we use our balancing to go through our tree
        let balancedNode = balanced(node)
        balancedNode.height = max(balancedNode.leftHeight, balancedNode.rightHeight) + 1
        return balancedNode
    }
    
    public mutating func remove(_ value: Element){
        root = remove(node: root, value: value)
    }
    
    private func remove(node: AVLNode<Element>?, value: Element) -> AVLNode<Element>? {
        
        guard let node = node else {
            return nil
        }
        
        if value == node.value{
            ///If the node is a leaf node, then return nil
            if node.leftChild == nil && node.rightChild == nil{
                return nil
            }
            ///if the node has no left child, return right child to reconnect to right subtree
            if node.leftChild == nil{
                return node.rightChild
            }
            ///if the node has no right child, return right child to reconnect to left subtree
            if node.rightChild == nil{
                return node.leftChild
            }
            /*
             this is the case where the node to be removed has both
             a left and a right child. you replace the node's value
             with the smallest value from the right subtree. you then
             call remove on the child to remove this swapped value.
             */
            node.value = node.rightChild!.min.value
            node.rightChild = remove(node: node.rightChild, value: node.value)
            
        } else if value < node.value{
            node.leftChild = remove(node: node.leftChild, value: value)
        } else {
            node.rightChild = remove(node: node.rightChild, value: value)
        }
       
        let balancedNode = balanced(node)
        balancedNode.height = max(balancedNode.leftHeight, balancedNode.rightHeight) + 1
        return balancedNode
    }
}


/*
 Rotations:
 the procedures used to balance a binary search tree are known as
 rotations. There are four rotations: Left rotation,
 left-right rotation, right rotation, and right-left rotation
 */

///Left Rotations
extension AVLTree{
    
    private func leftRotate(_ node: AVLNode<Element>) -> AVLNode<Element>{
        /*
         The right child is chosen as the pivot, this node will raplace rotated node as the root of the subtree(it will move up a level)
         */
        let pivot = node.rightChild!
        /*
         the node to be rotated will become the left child of the pivot
         this means the current left child of the pivot must be moved elsewhere
         */
        node.rightChild = pivot.leftChild
        ///the pivot's leftchild can now be set to the rotated node
        pivot.leftChild = node
        ///update the heights of the rotated node and the pivot
        ///Max(-1,-1) + 1 = 0 hence +1 is needed if it doesnt have neither left or right child
        node.height = max(node.leftHeight, node.rightHeight) + 1
        pivot.height = max(pivot.leftHeight, pivot.rightHeight) + 1
        ///return the pivot so it can replace the rotated node in the tree
        return pivot
    }
}


///Right Rotations
extension AVLTree{
    private func rightRotate(_ node: AVLNode<Element>) -> AVLNode<Element>{
        let pivot = node.leftChild!
        node.leftChild = pivot.rightChild
        pivot.rightChild = node
        node.height = max(node.leftHeight, node.rightHeight) + 1
        pivot.height = max(pivot.leftHeight, pivot.rightHeight) + 1
        return pivot
    }
}


///Right-left Rotations
extension AVLTree{
    private func rightLeftRotate(_ node: AVLNode<Element>) -> AVLNode<Element>{
        guard let rightChild = node.rightChild else {
            return node
        }
        ///Apply a right rotation on our right child
        node.rightChild = rightRotate(rightChild)
        ///then apply a left rotation to balance the tree
        return leftRotate(node)
    }
    
}


///Left-right Rotations
extension AVLTree{
    private func leftRightRotate(_ node: AVLNode<Element>) -> AVLNode<Element>{
        guard let leftChild = node.leftChild else {
            return node
        }
        node.leftChild = leftRotate(leftChild)
        return rightRotate(node)
    }
}


///Balancing
extension AVLTree{
    private func balanced(_ node: AVLNode<Element>) -> AVLNode<Element>{
        switch node.balancefactor {
        case 2:
            ///this suggests that the left child is heavier, means use right or left-right rotations
            if let leftChild = node.leftChild, leftChild.balancefactor == -1{
                return leftRightRotate(node)
            } else {
                return rightRotate(node)
            }
        case -2:
            ///this suggests that the right child is heavier, means use left or right-left rotations
            if let rightChild = node.rightChild, rightChild.balancefactor == 1{
                return rightLeftRotate(node)
            } else {
                return leftRotate(node)
            }
        default:
            ///this suggests that particular node is balanced
            return node
        }
    }
}

///pre-order traversal: ascending order
extension AVLNode{
    public func traversePreOrder(visit: (Element) -> Void){
        leftChild?.traversePreOrder(visit: visit)
        visit(value)
        rightChild?.traversePreOrder(visit: visit)
    }
    
}

extension AVLTree{

    public func contains(_ value: Element) -> Bool{
        var current = root
            
        ///Check if root is not nil
        while let node = current{
            if node.value == value{
                return true
            }
                
            ///if value is less than the current node then go to left child
            if value < node.value{
                current = node.leftChild
            }else{
            ///otherwise go to the right child
                current = node.rightChild
            }
        }
        return false
    }
    
    public func index(_ at: Int) -> Element?{
        var current = root?.value
        var count = 0
            
        root?.traversePreOrder(visit: { (element) in
            if count == at{
                current = element
            }
            count+=1
        })

        return current
    }
    
    
    public func indexOf(_ value:Element) -> Int?{
        var indexOf = 0
        var count = 0
            
        root?.traversePreOrder(visit: { (element) in
            if element == value{
                indexOf = count
            }
            count+=1
        })

        return indexOf
    }
    
    public func updateValue(_ value: Element){
        guard count > 0 else {
            return
        }
        var current = root
        
        ///Check if root is not nil
        while let node = current{
            if node.value == value{
                node.value = value
            }
            ///if value is less than the current node then go to left child
            if value < node.value{
                current = node.leftChild
            }else{
            ///otherwise go to the right child
                current = node.rightChild
            }
        }
    }
    
}

