//
//  CategoryViewController.swift
//  note_apollo_iOS
//
//  Created by Nency on 01/02/21.
//

import UIKit
import CoreData

class CategoryViewController: UIViewController {
    
    var noteVC: apolloNoteVC? = nil
    var selectedCategory: String? = nil
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var categoryList: [NoteCategory] = []
    
    @IBOutlet weak var txtAddCategory: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnAdd: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        getCategoryList()
        txtAddCategory.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
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
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        btnAdd.isEnabled = textField.hasText
        txtAddCategory.layer.borderColor = UIColor.systemGray.cgColor
    }
    
    @IBAction func addClicked(_ sender: Any) {
        if let newCategory = txtAddCategory.text {
            if !checkCategoryIsThere(newCategory) {
                addCategoryInList(name: newCategory)
            } else {
                txtAddCategory.layer.borderColor = UIColor.systemRed.cgColor
            }
        }
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
}

//MARK: - show Category
extension CategoryViewController: UITableViewDelegate, UITableViewDataSource{
    
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
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCategory = categoryList[indexPath.row].name
        noteVC?.noteCategoryName = selectedCategory ?? "UnCategory"
        tableView.reloadData()
    }
}
