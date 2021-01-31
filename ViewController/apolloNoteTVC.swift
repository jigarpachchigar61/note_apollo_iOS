//
//  apolloNoteTVC.swift
//  note_apollo_iOS
//
//  Created by Jigar Pachchigar on 28/01/21.
//  Copyright © 2017 Apple Developer. All rights reserved.
//

import UIKit
import CoreData

class apolloNoteTVC: UITableViewController {


    var notesArr = [Note]()
    
    let searchController = UISearchController(searchResultsController: nil)

    var managedObjectContext: NSManagedObjectContext? {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveNotes()
        
        self.navigationController?.navigationBar.tintColor = .gray
        tableView.delegate = self
        tableView.dataSource = self
        // Styles
        self.tableView.backgroundColor = UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        
        self.refreshControl = UIRefreshControl()


        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl!) // not required when using UITableViewController
    }

    @objc func refresh(_ sender: AnyObject) {
       // Code to refresh table view

        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        retrieveNotes()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesArr.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tbcell = tableView.dequeueReusableCell(withIdentifier: "noteTableViewCell", for: indexPath) as! apolloTVCell

        let note: Note = notesArr[indexPath.row]
        tbcell.configureCell(note: note)
        tbcell.backgroundColor = UIColor.clear
        
        return tbcell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {

        }
        
        tableView.reloadData()
        
    }
    
    @objc func refresh(sender:AnyObject) {
       // Code to refresh table view

        self.refreshControl!.endRefreshing()
    }
    
    

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        
        let delete = UITableViewRowAction(style: .destructive, title: "  ") { (action, indexPath) in
            
            let note = self.notesArr[indexPath.row]
            context.delete(note)
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            do {
                self.notesArr = try context.fetch(Note.fetchRequest())
            }
                
            catch {
                print("Sorry! Could't Delete Note.")
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()

        }
        
        delete.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "trashIcon"))
        
        return [delete]

    }
    
    // MARK: NSCoding
    func retrieveNotes() {
        managedObjectContext?.perform {
            
            self.fetchNotesFromCoreData { (notes) in
                if let notesAavil = notes {
                    self.notesArr = notesAavil
                    self.tableView.reloadData()
                }
                
            }
            
        }
        
    }
    
    func fetchNotesFromCoreData(completion: @escaping ([Note]?)->Void){
        managedObjectContext?.perform {
            var notesArr = [Note]()
            let request: NSFetchRequest<Note> = Note.fetchRequest()
            
            do {
                notesArr = try  self.managedObjectContext!.fetch(request)
                completion(notesArr)
                
            }
            
            catch {
                print("Sorry! Could not load note:\(error.localizedDescription)")
                
            }
            
        }
        
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                let noteDetailsViewController = segue.destination as! apolloNoteVC
                let selectedNote: Note = notesArr[indexPath.row]
                
                noteDetailsViewController.indexPath = indexPath.row
                noteDetailsViewController.isNoteAvail = false
                noteDetailsViewController.note = selectedNote
                
            }
            
        }
            
        else if segue.identifier == "addItem" {
            print("New note added")
            
        }

    }

}

extension apolloNoteTVC: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    // TODO
  }
}
