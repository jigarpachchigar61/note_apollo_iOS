//
//  CreateChooseCategoryViewController.swift
//  note_apollo_iOS
//
//  Created by Nency on 01/02/21.
//

import UIKit
import CoreData

class CreateChooseCategoryViewController: UIViewController {
    
    var noteVC: apolloNoteVC? = nil
    var selectedCategory: String? = nil
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var categoryList: [NoteCategory] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        getCategoryList()
    }
    
    //MARK: - bottomesheet
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
    
    func prepareBackgroundView(){
        let blurEffect = UIBlurEffect.init(style: .light)
        let visualEffect = UIVisualEffectView.init(effect: blurEffect)
        let bluredView = UIVisualEffectView.init(effect: blurEffect)
        bluredView.contentView.addSubview(visualEffect)
        
        visualEffect.frame = UIScreen.main.bounds
        bluredView.frame = UIScreen.main.bounds
        
        view.insertSubview(bluredView, at: 0)
    }
    
    @IBAction func addClicked(_ sender: Any) {
        
        let alert = UIAlertController(title: "Add Category", message: "Enter a text", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
            textField.placeholder = "Category"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let text = alert?.textFields![0].text ?? ""
            let newCategory = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if newCategory.isEmpty{
                self.showAlert("Error", "Category cannot be blank.")
            } else if !self.checkCategoryIsThere(newCategory) {
                self.addCategoryInList(name: newCategory)
            } else {
                self.showAlert("Error", "Category is already present.")
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlert(_ title: String, _ msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in }))
        self.present(alert, animated: true, completion: nil)
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
    
    override func viewWillDisappear(_ animated: Bool) {
        noteVC?.bottomSheetClose()
    }
}

//MARK: - show Category
extension CreateChooseCategoryViewController: UITableViewDelegate, UITableViewDataSource{
    
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
    
    func addCategoryInList(name: String){
        do {
            let category = NoteCategory(context: context)
            category.name = name
            try context.save()
            getCategoryList()
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
        if category.name == selectedCategory {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCategory = categoryList[indexPath.row].name
        noteVC?.noteCategoryName = selectedCategory ?? "UnCategory"
        tableView.reloadData()
    }
}
