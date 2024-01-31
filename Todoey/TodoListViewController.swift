//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Himani Goyal on 22/01/24.
//

import UIKit

struct TodoListItem: Codable {
    var title: String
    var done: Bool
}

class TodoListViewController: UITableViewController {
    var itemsArray: [TodoListItem] = [TodoListItem]()
    
    let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist", conformingTo: .propertyList)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        itemsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoItemCell", for: indexPath)
        cell.textLabel?.text = itemsArray[indexPath.row].title
        
        cell.accessoryType = itemsArray[indexPath.row].done ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = itemsArray[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath)
        
        cell?.accessoryType = item.done ? .none : .checkmark
        itemsArray[indexPath.row].done.toggle()
        
        self.updateData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(
            title: "Add new todoey item",
            message: nil,
            preferredStyle: .alert
        )
        
        alert.addTextField { alertTextField in
            textField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        let action = UIAlertAction(
            title: "Add item",
            style: .default
        ) { [weak self] (action) in
            guard let self = self else { return }
            if let text = textField.text {
                self.save(item: TodoListItem(title: text, done: false))
                self.tableView.reloadData()
            }
        }
        
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    private func save(item: TodoListItem) {
        self.itemsArray.append(item)
        updateData()
    }
    
    private func updateData() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(itemsArray)
            try data.write(to: filePath!)
        } catch {
            print("error while encoding")
        }
    }
    
    private func loadData() {
        let decoder = PropertyListDecoder()
        if let fileUrl = self.filePath,
           let data = try? Data(contentsOf: fileUrl) {
            do {
                let decodedItems = try decoder.decode([TodoListItem].self, from: data)
                self.itemsArray = decodedItems
            } catch {
                print("Could not decode saved items")
            }
        }
    }
}
