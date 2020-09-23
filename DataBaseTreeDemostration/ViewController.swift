//
//  ViewController.swift
//  DataBaseTreeDemostration
//
//  Created by  Macbook on 22.09.2020.
//  Copyright © 2020 Golovelv Maxim. All rights reserved.
//

import UIKit

enum TableEditingMode {
    case database
    case cash
    case none
    
    func configureButtons(databaseButtons: [UIButton], cashButtons: [UIButton]) {
        switch self {
        case .database:
            databaseButtons.forEach({ $0.isEnabled = true })
            cashButtons.forEach({ $0.isEnabled = false })
        case .cash:
            databaseButtons.forEach({ $0.isEnabled = false })
            cashButtons.forEach({ $0.isEnabled = true })
        case .none:
            databaseButtons.forEach({ $0.isEnabled = false })
            cashButtons.forEach({ $0.isEnabled = false })
        }
    }
}

class ViewController: UIViewController, Alertable {

    @IBOutlet weak var cashTableView: UITableView!
    @IBOutlet weak var databaseTableView: UITableView!
    
    @IBOutlet weak var shiftButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    var editingMode: TableEditingMode = .none
    var cellId = "NodeTableViewCell"

    lazy var defaultTree: Node<Int> = {
        
        let one = Node(value: 100)
        let two = Node(value: 200)
        let tree = Node(value: 300)
        let four = Node(value: 400)
        let five = Node(value: 500)
        let six = Node(value: 600)
        let seven = Node(value: 700)

        one.add(child: two)
        two.add(child: tree)
        two.add(child: four)
        tree.add(child: five)
        four.add(child: six)
        four.add(child: seven)
        
        return one
    }()
    
    var casheTree: Node<Int>?
    var databaseTree: Node<Int>?
    
    var databaseNodes = [Node<Int>]()
    var casheNodes = [Node<Int>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        [cashTableView, databaseTableView].forEach({
            $0?.tableFooterView = UIView()
            $0?.register(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
            $0?.dataSource = self
            $0?.delegate = self
        })
        
        databaseTree = defaultTree.deepCopy()
        databaseNodes = databaseTree?.getAllElements() ?? []
    }
    
    @IBAction func shiftTapped(_ sender: Any) {
        
        if let index = databaseTableView.indexPathForSelectedRow {
            let node = databaseNodes[index.row]
            let copy = node.copy() as! Node<Int>
            
            if casheTree == nil {
                casheTree = copy
            } else {
                casheTree = casheTree?.merge(node: node)
            }
            
            casheNodes = casheTree?.getAllElements() ?? []
            cashTableView.reloadData()
        }
    }

    @IBAction func addTapped(_ sender: Any) {
        if let index = cashTableView.indexPathForSelectedRow {
            let node = casheNodes[index.row]
            
            showInputDialog(title: "Input value", actionTitle: "Done", cancelTitle: "Cancel", inputKeyboardType: .numberPad) { [weak self] (query) in
                
                guard let query = query, let intValue = Int(query) else { return }
                
                node.add(child: Node(value: intValue))
                
                self?.casheNodes = self?.casheTree?.getAllElements() ?? []
                self?.cashTableView.reloadData()
                
                self?.cashTableView.performBatchUpdates({}) { [weak self] (_) in
                    self?.cashTableView.selectRow(at: index, animated: false, scrollPosition: .none)
                }
            }
        }
    }
    
    @IBAction func removeTapped(_ sender: Any) {
        if let index = cashTableView.indexPathForSelectedRow {
            let node = casheNodes[index.row]
            casheTree?.remove(node: node)
            
            
            casheNodes = casheTree?.getAllElements() ?? []
            cashTableView.reloadData()
            
            cashTableView.performBatchUpdates({}) { [weak self] (_) in
                self?.cashTableView.selectRow(at: index, animated: false, scrollPosition: .none)
            }
        }
    }

    @IBAction func editTapped(_ sender: Any) {
        if let index = cashTableView.indexPathForSelectedRow {
            let node = casheNodes[index.row]
                
            showInputDialog(title: "Input value", actionTitle: "Done", cancelTitle: "Cancel", inputKeyboardType: .numberPad) { [weak self] (query) in
                
                guard let query = query, let intValue = Int(query) else { return }
                
                node.value = intValue
                
                self?.casheNodes = self?.casheTree?.getAllElements() ?? []
                self?.cashTableView.reloadData()
                
                self?.cashTableView.performBatchUpdates({}) { [weak self] (_) in
                    self?.cashTableView.selectRow(at: index, animated: false, scrollPosition: .none)
                }
            }
        }
    }
    
    @IBAction func applyTapped(_ sender: Any) {
        
        if let casheTree = casheTree {
            databaseTree?.merge(tree: casheTree)
        }
        databaseNodes = databaseTree?.getAllElements() ?? []
        databaseTableView.reloadData()
    }
    
    @IBAction func resetTapped(_ sender: Any) {
        casheNodes.removeAll()
        casheTree = nil
        databaseTree = defaultTree.deepCopy()
        databaseNodes = databaseTree?.getAllElements() ?? []
        cashTableView.reloadData()
        databaseTableView.reloadData()
        editingMode = .none
        editingMode.configureButtons(databaseButtons: [shiftButton], cashButtons: [addButton, removeButton, editButton, applyButton, resetButton])
    }
}

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == databaseTableView {
            return databaseNodes.count
        }
        return casheNodes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! NodeTableViewCell
        
        let row = indexPath.row
        let node = tableView == databaseTableView ? databaseNodes[row] : casheNodes[row]
        let offset = node.height == 0 ? "" : Array(1...node.height).reduce(into: "", { res, _ in res.append("    ") })
        cell.valueButton.setTitle("\(offset)\(node.value)", for: .normal)
        cell.valueButton.isEnabled = !node.isDeleted
        return cell
    }
}

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == databaseTableView {
            editingMode = .database
            if let index = cashTableView.indexPathForSelectedRow {
                cashTableView.deselectRow(at: index, animated: true)
            }
        } else {
            editingMode = .cash
            if let index = databaseTableView.indexPathForSelectedRow {
                databaseTableView.deselectRow(at: index, animated: true)
            }
        }
        
        editingMode.configureButtons(databaseButtons: [shiftButton], cashButtons: [addButton, removeButton, editButton, applyButton, resetButton])
    }
    
}