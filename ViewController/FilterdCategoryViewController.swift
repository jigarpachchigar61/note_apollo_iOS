//
//  CategoryViewController.swift
//  note_apollo_iOS
//
//  Created by Nency on 01/02/21.
//

import UIKit
import CoreData

class FilterdCategoryViewController: UIViewController {
    var noteTVC: apolloNoteTVC? = nil
    var selectedCategory: [NoteCategory] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var categoryList: [NoteCategory] = []
    
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        getCategoryList()
    }
    
    // MARK: - bottom sheet
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareBackgroundView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            let frame = self?.view.frame
            let yComponent = UIScreen.main.bounds.height - 500
            self?.view.frame = CGRect(x: 0, y: yComponent, width: frame!.width, height: frame!.height)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        noteTVC?.bottomSheetClose()
    }
    
    func prepareBackgroundView(){
        let blurEffect = UIBlurEffect.init(style: .light)
        let visualEffect = UIVisualEffectView.init(effect: blurEffect)
        let bluredView = UIVisualEffectView.init(effect: blurEffect)
        bluredView.contentView.addSubview(visualEffect)
        
        visualEffect.frame = UIScreen.main.bounds
        bluredView.frame = UIScreen.main.bounds
        
        view.insertSubview(bluredView, at: 0)
    }
    
    //MARK: - get old or create a new Category
    func checkCategoryIsThere(_ category: String) -> Bool{
        let request: NSFetchRequest<NoteCategory> = NoteCategory.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", category)
        do {
            let categoryList = try context.fetch(request)
            if categoryList.count > 0{
                return true
            }
        } catch {
            print("Error loading provider \(error.localizedDescription)")
        }
        return false
    }
    
    
    @IBAction func closeClicked(_ sender: Any) {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
    
    // MARk: - category name edit
    @IBAction func editClicked(_ sender: Any) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        if tableView.isEditing {
            btnEdit.setTitle("Done", for: .normal)
            btnEdit.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        } else {
            btnEdit.setTitle("Edit", for: .normal)
            btnEdit.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        }
    }
}

//MARK: - show Category
extension FilterdCategoryViewController: UITableViewDelegate, UITableViewDataSource{
    
    func getCategoryList(){
        let request: NSFetchRequest<NoteCategory> = NoteCategory.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        do {
            categoryList = try context.fetch(request)
            tableView.reloadData()
        } catch {
            print("Error loading Category \(error.localizedDescription)")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryViewCell", for: indexPath) as! CategoryViewCell
        let category = categoryList[indexPath.row]
        cell.initCell(name: category.name ?? "")
        if selectedCategory.contains(categoryList[indexPath.row]) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    //MARK: - tableView delegate to detect editstyle change
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteCategory(category: categoryList[indexPath.row])
        }
    }
    
    //MARK: - delete category from list
    func deleteCategory(category: NoteCategory){
        context.delete(category)
        do {
            try context.save()
            getCategoryList()
        } catch {
            alertMsg(title: "Error", msg: "Category contains notes so can't delete this category")
        }
    }
    
    func alertMsg(title: String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { _ in }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing{
            showEditCategoryAlert(category: categoryList[indexPath.row])
        } else if let index = selectedCategory.firstIndex(of:categoryList[indexPath.row]) {
            selectedCategory.remove(at: index)
        } else {
            selectedCategory.append(categoryList[indexPath.row])
        }
        noteTVC?.selectedCategoryList = selectedCategory
        tableView.reloadData()
    }
    
    func updateDataList(){
        do {
            try context.save()
            getCategoryList()
        } catch {
            alertMsg(title: "Error", msg: "something went wrong")
        }
    }
    
    //MARK: - Show alert Box to get updated name of provider
    func showEditCategoryAlert(category: NoteCategory) {
        let alert = UIAlertController(title: "Edit Category Name", message: "Enter a text", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = category.name
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            category.name = textField?.text ?? ""
            self.updateDataList()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in }))
        
        
        self.present(alert, animated: true, completion: nil)
    }
}
