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
    var searchText = ""
    @IBOutlet weak var btnCategory: UIBarButtonItem!
    var selectedCategoryList: [NoteCategory] = []{
        didSet{
            selectedCategoryListName = selectedCategoryList.map { (category) -> String in
                category.name ?? ""
            }
        }
    }
    var selectedCategoryListName: [String] = []{
        didSet{
            retrieveNotes()
        }
    }
    
    let searchController = UISearchController(searchResultsController: nil)

    var managedObjectContext: NSManagedObjectContext? {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSearchBar()
        retrieveCategory()
        
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
        retrieveCategory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
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
    

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            
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
        
      //  delete.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "trashIcon"))
    
        
        return [delete]

    }
    
    // MARK: NSCoding
    func retrieveNotes() {
        managedObjectContext?.perform {
            
            self.fetchNotesFromCoreData { (notes) in
                if let notesAavil = notes {
                    self.notesArr = notesAavil
                    self.tableView.reloadData()
                    self.refreshControl!.endRefreshing()
                }
                
            }
            
        }
        
    }
    
    func retrieveCategory(){
        let request: NSFetchRequest<NoteCategory> = NoteCategory.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        do {
            selectedCategoryList = try managedObjectContext?.fetch(request) ?? []
        } catch {
            print("Error loading Category \(error.localizedDescription)")
        }
    }
    
    func fetchNotesFromCoreData(completion: @escaping ([Note]?)->Void){
        managedObjectContext?.perform {
            var notesArr = [Note]()
            let request: NSFetchRequest<Note> = Note.fetchRequest()
            var requestPredicate = NSPredicate(format: "noteCategory.name in %@ ", self.selectedCategoryListName)
            if !self.searchText.isEmpty {
                let searchPredict = NSPredicate(format: "noteName CONTAINS[cd] %@ OR noteDescription CONTAINS[cd] %@", self.searchText, self.searchText)
                requestPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [requestPredicate, searchPredict])
            }
            request.predicate = requestPredicate
            
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
                
                noteDetailsViewController.vcCallback = {
                    self.retrieveNotes()
                }
            }
            
        }
            
        else if segue.identifier == "addItem" {
            print("New note added")
            
            if let naVC  = segue.destination as? UINavigationController,
               let noteDetailVC = naVC.viewControllers.first as? apolloNoteVC
            
            {
                noteDetailVC.isNoteAvail = false
                noteDetailVC.vcCallback = {
                    self.retrieveNotes()
                }
            }
            
            
        }
        
        else if segue.identifier == "notesOnMap" {
            let destination = segue.destination as! LocationViewController
            var noteLocation:[String: CLLocationCoordinate2D] = [:]
            notesArr.forEach { (noteData) in
                if let title = noteData.noteName {
                noteLocation[title] =
                    CLLocationCoordinate2D(latitude: noteData.noteLatitude, longitude: noteData.noteLongitude)
                }
            }
            destination.noteLocation = noteLocation
        }
    }
    
    @IBAction func categoryClicked(_ sender: UIBarButtonItem) {
        addCategoryVCInBottonSheet()
    }
    func addCategoryVCInBottonSheet() {
        // 1- Init bottomSheetVC
        let bottomSheetVC =
        self.storyboard!.instantiateViewController(withIdentifier: "FilterdCategoryViewController") as!
            FilterdCategoryViewController
        bottomSheetVC.noteTVC = self
        bottomSheetVC.selectedCategory = selectedCategoryList

        // 2- Add bottomSheetVC as a child view
        self.addChild(bottomSheetVC)
        self.view.addSubview(bottomSheetVC.view)
        bottomSheetVC.didMove(toParent: self)

        // 3- Adjust bottomSheet frame and initial position.
        let height = view.frame.height
        let width  = view.frame.width
        bottomSheetVC.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
        btnCategory.isEnabled = false
    }
    
    func bottomSheetClose(){
        btnCategory.isEnabled = true
    }
}

extension apolloNoteTVC: UISearchResultsUpdating, UISearchBarDelegate {
    
    func initSearchBar(){
//        self.searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.delegate = self // Monitor when the search button is tapped.

        // Place the search bar in the navigation bar.
        navigationItem.searchController = searchController
        
        // Make the search bar always visible.
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        searchText = searchController.searchBar.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        retrieveNotes()
    }
}
