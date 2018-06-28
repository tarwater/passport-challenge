//
//  ProfileTableViewController.swift
//  passport-challenge
//
//  Created by Holt, Robert on 6/25/18.
//  Copyright © 2018 Holt, Robert. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Kingfisher

class ProfileTableViewController: UITableViewController {
    
    var profiles = [Profile]()
    var filter = "none"
    
    let blue = UIColor(red: 155/255, green: 212/255, blue: 214/255, alpha: 1)
    let pink = UIColor(red: 217/255, green: 187/255, blue: 215/255, alpha: 1)
    let brown = UIColor(red: 204/255, green: 183/255, blue: 157/255, alpha: 1) // My colors
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let ref = Database.database().reference()
        ref.child("profiles").queryOrderedByKey().observe(.value, with: {(data) in  // ordering by key == order by creation date, ascending
      
            for child in data.children {
                let snap = child as! DataSnapshot
                let dict = snap.value as! NSDictionary
                
                let id = snap.key
                let hobbies = dict["hobbies"] as? String ?? ""

                if let found = self.profiles.first(where: {$0.id == id}) { // does pet already exist?
                    found.hobbies = hobbies // update the hobbies
                } else {
                    let name = dict["name"] as? String ?? ""
                    let age = dict["age"] as? Int ?? 0
                    let gender = dict["gender"] as? String ?? ""
                    let image = dict["image"] as? String ?? ""
                    let profile = Profile(name: name, gender: gender, age: age, hobbies: hobbies, image: image, id: id) // create new pet profile
                    self.profiles += [profile]
                }
            }
            
            self.tableView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
        
        setRealTimeUpdates()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profiles.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let profile = profiles[indexPath.row]
        
        // filter out unwanted profiles by setting cell height to 0
        if filter == "none" || profile.gender == filter{
            return 80
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> ProfileTableViewCell {
        let identifier = "cell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? ProfileTableViewCell else {
            fatalError("Dequeued cell is not a ProfileTableViewCell")
        }

        // Configure the cell...
        let profile = profiles[indexPath.row]
        cell.nameLabel.text = profile.name
        
        cell.profileImage.layer.masksToBounds = true
        cell.profileImage.layer.borderWidth = 2
        cell.profileImage.layer.cornerRadius = cell.profileImage.bounds.width / 2
        cell.profileImage.layer.borderColor = profile.gender == "male" ? self.blue.cgColor : self.pink.cgColor // set appropriate image border color
        cell.hobbiesLabel.text = profile.hobbies

        if(profile.image != ""){  // Did they pick an avatar?
            let url = URL(string: profile.image)
            cell.profileImage.kf.setImage(with: url) // load the image
        }
        
        return cell
    }
    
    
    @IBAction func menuClick(_ sender: Any) {
        let message = NSLocalizedString("Filter", comment: "Filters and sorting")
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)  // using an alert for sorting/filtering options
        
        if filter == "none" {
            alert.addAction(UIAlertAction(title: "Males only", style: .default) {  _ in
                self.filter = "male"
                self.tableView.reloadData()
            })
            
            alert.addAction(UIAlertAction(title: "Females only", style: .default) {  _ in
                self.filter = "female"
                self.tableView.reloadData()
            })
        } else if filter == "male" {
            alert.addAction(UIAlertAction(title: "Males only (remove)", style: .default) {  _ in
                self.filter = "none"
                self.tableView.reloadData()
            })
            
            alert.addAction(UIAlertAction(title: "Females only", style: .default) {  _ in
                self.filter = "female"
                self.tableView.reloadData()
            })
        } else {
            alert.addAction(UIAlertAction(title: "Males only", style: .default) {  _ in
                self.filter = "male"
                self.tableView.reloadData()
            })
            
            alert.addAction(UIAlertAction(title: "Females only (remove)", style: .default) {  _ in
                self.filter = "none"
                self.tableView.reloadData()
            })
        }
        
        alert.addAction(UIAlertAction(title: "Sort oldest first", style: .default) { _ in
            self.sortList(type: "oldest")
        })
        
        alert.addAction(UIAlertAction(title: "Sort youngest first", style: .default) {  _ in
            self.sortList(type: "youngest")
        })
        
        alert.addAction(UIAlertAction(title: "Sort A-Z", style: .default) {  _ in
            self.sortList(type: "a-z")
        })
        
        alert.addAction(UIAlertAction(title: "Sort Z-A", style: .default) { _ in
            self.sortList(type: "z-a")
        })
        
        alert.addAction(UIAlertAction(title: "Default sort", style: .cancel) { _ in
            self.sortList(type: "default")
        })
        
        present(alert, animated: true, completion: nil)
    }
    
    
    func sortList(type: String){
        switch type {  // switch to handle various types of list sorting
        case "a-z":
            profiles.sort {(o1, o2) -> Bool in
                return o1.name.lowercased() < o2.name.lowercased()
            }
            self.tableView.reloadData()
        case "z-a":
            profiles.sort {(o1, o2) -> Bool in
                return o1.name.lowercased() > o2.name.lowercased()
            }
            self.tableView.reloadData()
        case "oldest":
            profiles.sort {(o1, o2) -> Bool in
                return o1.age > o2.age
            }
            self.tableView.reloadData()
            break
        case "youngest":
            profiles.sort {(o1, o2) -> Bool in
                return o1.age < o2.age
            }
            self.tableView.reloadData()
            break
        default:
            profiles.sort {(o1, o2) -> Bool in
                return o1.id < o2.id
            }
            self.tableView.reloadData()
            break
        }
        
    }
    
    // this method sets real-time updates on the profiles. this is really cool. thanks firebase.
    func setRealTimeUpdates(){
        let ref = Database.database().reference()
        ref.child("profiles").observe(DataEventType.childChanged, with: {(snapshot) in
            let id = snapshot.key
            let dict = snapshot.value as! NSDictionary
            let hobbies = dict["hobbies"] as? String ?? ""
            let image = dict["image"] as? String ?? ""
            if let found = self.profiles.first(where: {$0.id == id}) { // this pet already exists?
                found.hobbies = hobbies // update the hobbies
                found.image = image // update the image (can be slow depending on upload)
            } else {
                let name = dict["name"] as? String ?? ""
                let age = dict["age"] as? Int ?? 0
                let gender = dict["gender"] as? String ?? ""
                let image = image
                let profile = Profile(name: name, gender: gender, age: age, hobbies: hobbies, image: image, id: id)
                self.profiles += [profile]
            }
            self.tableView.reloadData()

        })
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? ProfileViewController {
            dest.profile = profiles[(tableView.indexPathForSelectedRow?.row)!] // pass the selected profile to the controller
        }
    }
}
