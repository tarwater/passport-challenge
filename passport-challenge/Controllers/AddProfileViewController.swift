//
//  AddProfileViewController.swift
//  passport-challenge
//
//  Created by Holt, Robert on 6/26/18.
//  Copyright © 2018 Holt, Robert. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase

class AddProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var ageField: UITextField!
    @IBOutlet weak var genderPicker: UISegmentedControl!
    @IBOutlet weak var hobbiesField: UITextView!
    @IBOutlet weak var hobbiesHeight: NSLayoutConstraint!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    let storage = Storage.storage()
    var storageRef: StorageReference?
    
    var gender = "male"
    
    let blue = UIColor(red: 155/255, green: 212/255, blue: 214/255, alpha: 1)
    let pink = UIColor(red: 217/255, green: 187/255, blue: 215/255, alpha: 1)
    let brown = UIColor(red: 204/255, green: 183/255, blue: 157/255, alpha: 1)
    
    var imageChosen = false // flag indicating whether or not the user provided an image
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 1.5
        imageView.layer.borderColor = brown.cgColor
        imageView.layer.cornerRadius = imageView.bounds.width/2
        
        hobbiesField.layer.borderColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1).cgColor
        hobbiesField.layer.borderWidth = 0.5
        hobbiesField.layer.cornerRadius = 5.0
        
        saveButton.isEnabled = false // saving is disabled until a name is entered
        
        nameField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged) // register for changes to the name field

        let killKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)) // register a gesture recognizer for dismissing the keyboard
        view.addGestureRecognizer(killKeyboardGesture)
        
        // you can tap the default avatar to select an image
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:))) // register a gesture recognizer for uploading images
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        storageRef = storage.reference()
        
        // register keyboard events, so the view can be adjusted accordingly
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func genderControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex { // change image border and segment control color depending on selected gender
        case 0:
            gender = "male"
            sender.tintColor = blue
            imageView.layer.borderColor = blue.cgColor
        case 1:
            gender = "female"
            sender.tintColor = pink
            imageView.layer.borderColor = pink.cgColor
        default:
            break
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
       saveButton.isEnabled = (textField.text != "") // can't save without a name
    }
    
    // stuff for uploading an image
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        NSLog("\(info)")
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        imagePickerController(picker, pickedImage: image)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, pickedImage: UIImage?) {
        imageView.image = pickedImage
        imageChosen = true
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) { // save button
        
        let name = nameField.text ?? ""
        let hobbies = hobbiesField.text ?? ""
        let age = Int(ageField.text!) ?? -1 // default age is -1, which displays as "unknown"
        
        let profile = [
            "name": name,
            "age": age,
            "hobbies": hobbies,
            "gender": gender
            ] as [String : Any]
        
        let ref = Database.database().reference().child("profiles").childByAutoId() // get a reference to the newly saved profile
        ref.setValue(profile)  // save our pet's data
        
        if(imageChosen == true){
            let imageData = UIImagePNGRepresentation(imageView.image!) //get the profile image data
            let id = ref.key  // id = the id of the profile
            let imageRef = storageRef?.child(id) // the image will be stored under the pet's ID
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/png" // set content type of upload
            
            imageRef?.putData(imageData!, metadata: metadata) { (metadata, error) in
                imageRef?.downloadURL { (url, error) in
                    guard let downloadURL = url else {  // get the download URL of the newly uploaded image
                        // Uh-oh, an error occurred!
                        return
                    }
                    ref.child("image").setValue(downloadURL.absoluteString) // give the URL to the pet object in the database
                    self.imageChosen = false
                    self.dismiss(animated: true, completion: nil)
                }
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: Keyboard show/hide stuff
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    var keyboardSize: CGFloat? = nil;
    
    // methods for adjusting the hobbies text field height constraint when keyboard shows/hides
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            hobbiesHeight.constant = 310 - keyboardSize.height - 8
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            hobbiesHeight.constant = 310
        }
    }
}
