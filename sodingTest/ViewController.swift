//
//  ViewController.swift
//  sodingTest
//
//  Created by Kittipol Munkatitum on 7/2/2560 BE.
//  Copyright © 2560 Kittipol Munkatitum. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tasks: [NSManagedObject] = []

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "TEST"
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TASK")
        do {
            tasks = try managedContext.fetch(fetchRequest)
            print(tasks.count)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func add(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New task",
                                      message: "Add a new task",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] action in
            
            guard let textField = alert.textFields?.first,
                let nameToSave = textField.text else {
                    return
            }
            self.save(name: nameToSave)
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    func editTask(oldName: String)  {
        let alert = UIAlertController(title: "Edit task",
                                      message: "Edit a new task",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] action in
            
            guard let textField = alert.textFields?.first,
                let nameToSave = textField.text else {
                    return
            }
            
            self.updateName(oldName: oldName, newName: nameToSave)
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    func updateName(oldName: String, newName: String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
     
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "TASK")
        let predicate = NSPredicate(format: "task = '\(oldName)'")
        fetchRequest.predicate = predicate
        do
        {
            let test = try context.fetch(fetchRequest)
            if test.count == 1
            {
                let objectUpdate = test[0] as! NSManagedObject
                objectUpdate.setValue(newName, forKey: "task")

                do{
                    try context.save()
                }
                catch
                {
                    print(error)
                }
            }
        }
        catch
        {
            print(error)
        }
        
    }
    
    func deleteName(oldName: String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
         let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "TASK")
        fetchRequest.predicate = NSPredicate(format: "task = '\(oldName)'")
        
        do {
            let array_users = try context.fetch(fetchRequest)
            for user in array_users as! [NSManagedObject] {
                context.delete(user)
                self.viewWillAppear(true)
            }
            do {
                try context.save()
                tableView.reloadData()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            } catch {
                
            }
            
        } catch {
            print("Error with request: \(error)")
        }
    }
    
    
    
    func save(name: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "TASK", in: managedContext)!
        let task = NSManagedObject(entity: entity, insertInto: managedContext)
        
        task.setValue(name, forKeyPath: "task")
     
        do {
            try managedContext.save()
            tasks.append(task)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
            let task = tasks[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = task.value(forKeyPath: "task") as? String
            return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            let edit = self.tasks[indexPath.row].value(forKey: "task") as? String ?? ""
            self.editTask(oldName: edit)
        }
        edit.backgroundColor = UIColor.lightGray
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            let delete = self.tasks[indexPath.row].value(forKey: "task") as? String ?? ""
            self.deleteName(oldName: delete)
        }
        delete.backgroundColor = UIColor.red
        
        return [delete, edit]
    }


}


