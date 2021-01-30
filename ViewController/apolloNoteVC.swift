//
//  apolloNoteVC.swift
//  note_apollo_iOS
//
//  Created by Jigar Pachchigar on 28/01/21.
//  Copyright © 2017 Apple Developer. All rights reserved.
//

import UIKit
import CoreData

class apolloNoteVC: UIViewController, UITextFieldDelegate,  UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate {

    
    @IBOutlet weak var notesTitle: UITextField!
    @IBOutlet weak var notesDesc: UITextView!
    
    @IBOutlet weak var notesDetail: UIView!

    @IBOutlet weak var noteImageView: UIImageView!

    @IBOutlet weak var notesImgView: UIView!
    
    
    var managedObjectContext: NSManagedObjectContext? {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
    }
    
    var notesResFetch: NSFetchedResultsController<Note>!
    var notesArr = [Note]()
    var note: Note?
    var isNoteAvail = false
    var indexPath: Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegates
        notesTitle.delegate = self
        notesDesc.delegate = self
        
        
        // Load Note Data
        if let noteData = note {
            notesTitle.text = noteData.noteName
            notesDesc.text = noteData.noteDescription
            noteImageView.image = UIImage(data: noteData.noteImage! as Data)

        }
        
        //Check Title Avail
        if notesTitle.text != "" {
            isNoteAvail = true
        }
        
    
        // Setting Styles
        notesDetail.layer.shadowColor =  UIColor(red:0/255.0, green:0/255.0, blue:0/255.0, alpha: 1.0).cgColor
        notesDetail.layer.shadowOffset = CGSize(width: 0.75, height: 0.75)
        notesDetail.layer.shadowRadius = 1.5
        notesDetail.layer.shadowOpacity = 0.2
        notesDetail.layer.cornerRadius = 2
        
        notesImgView.layer.shadowColor =   UIColor(red:62/255.0, green:52/255.0, blue:139/255.0, alpha: 1.0).cgColor
        notesImgView.layer.shadowOffset = CGSize(width: 0.75, height: 0.75)
        notesImgView.layer.shadowRadius = 1.5
        notesImgView.layer.shadowOpacity = 0.2
        notesImgView.layer.cornerRadius = 2
        
        noteImageView.layer.cornerRadius = 2
        
        notesTitle.bottomBorder()

    }

   
    
    // Check Image Button Press
    @IBAction func ChkImgBtnPress(_ sender: Any) {
        
        let ImgPicker = UIImagePickerController()
        ImgPicker.delegate = self
        ImgPicker.allowsEditing = true
        
        let alertController = UIAlertController(title: "Add an Image", message: "Select From", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            ImgPicker.sourceType = .camera
            self.present(ImgPicker, animated: true, completion: nil)
            
        }
        
        let LibraryAction = UIAlertAction(title: "Photos Library", style: .default) { (action) in
            ImgPicker.sourceType = .photoLibrary
            self.present(ImgPicker, animated: true, completion: nil)
            
        }
        
        let albumAction = UIAlertAction(title: "Albums", style: .default) { (action) in
            ImgPicker.sourceType = .savedPhotosAlbum
            self.present(ImgPicker, animated: true, completion: nil)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alertController.addAction(cameraAction)
        alertController.addAction(LibraryAction)
        alertController.addAction(albumAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    //MARK: - Save Note Data Using Core Data
    
    func saveNoteData(completion: @escaping ()->Void){
        managedObjectContext!.perform {
            do {
                try self.managedObjectContext?.save()
                completion()
                print("Note Saved.")
                
            }
            
            catch let error {
                print("Could not save note to CoreData: \(error.localizedDescription)")
                
            }
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    //MARK: - Check Finish Image Media
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    
    //MARK: - Press Cancel Button
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        let isPresentMode = presentingViewController is UINavigationController
        
        if isPresentMode {
            dismiss(animated: true, completion: nil)
            
        }
        
        else {
            navigationController?.popViewController(animated: true)
            
        }
        
    }

    //MARK: - Save Button Pressed
    @IBAction func saveButtonWasPressed(_ sender: UIBarButtonItem) {
        if notesTitle.text == "" || notesTitle.text == "Note Title" || notesDesc.text == "" || notesDesc.text == "Note Description" {
            
            let alertController = UIAlertController(title: "Sorry! Empty Note Can't be Save", message:"Please Add Note Title And Descriptions", preferredStyle: UIAlertController.Style.alert)
            let OK = UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil)
            
            alertController.addAction(OK)
            
            self.present(alertController, animated: true, completion: nil)
            
        }
        
        else {
            if (isNoteAvail == false) {
                let noteTitle = notesTitle.text
                let noteDesc = notesDesc.text
                
                if let moc = managedObjectContext {
                    let note = Note(context: moc)

                    if let data : Data  = self.noteImageView.image!.pngData() {
                        note.noteImage = data as NSData as Data
                    }
                
                    note.noteName = noteTitle
                    note.noteDescription = noteDesc
                
                    saveNoteData() {
                        
                        let isPresentingInAddFluidPatientMode = self.presentingViewController is UINavigationController
                        
                        if isPresentingInAddFluidPatientMode {
                            self.dismiss(animated: true, completion: nil)
                            
                        }
                        
                        else {
                            self.navigationController?.popViewController(animated: true)
                            
                        }

                    }

                }
            
            }
            
            else if (isNoteAvail == true) {
                
                let note = self.note
                
                let managedObject = note
                managedObject!.setValue(notesTitle.text, forKey: "noteName")
                managedObject!.setValue(notesDesc.text, forKey: "noteDescription")
                
                if let data = self.noteImageView.image!.jpegData(compressionQuality: 1.0) {
                    managedObject!.setValue(data, forKey: "noteImage")
                }
                
                do {
                    try context.save()
                    
                    let isPresentingInAddFluidPatientMode = self.presentingViewController is UINavigationController
                    
                    if isPresentingInAddFluidPatientMode {
                        self.dismiss(animated: true, completion: nil)
                        
                    }
                        
                    else {
                        self.navigationController?.popViewController(animated: true)
                        
                    }

                }
                
                catch {
                    print("Sorry!Can't Update Note.")
                }
            }

        }

    }
    
    //MARK: - Check Finish Image Media

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true, completion: nil)
        
        if let image = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage {
            self.noteImageView.image = image
            
        }
    }
    
    
    //MARK: - note text edit
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView.text == "Note Description") {
            textView.text = ""
            
        }
        
    }
    
    //MARK: - textfield text change

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
            
        }
        
        return true
        
    }
    
    //MARK: - textfield should return
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
        
    }
    

}

extension UITextField {
    
    //bottom border
    func bottomBorder() {
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor(red: 245.0/255.0, green: 79.0/255.0, blue: 80.0/255.0, alpha: 1.0).cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        
       
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
    
    
}
