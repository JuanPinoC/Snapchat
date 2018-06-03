//
//  ElegirUsuarioViewController.swift
//  Snapchat
///Users/jpino/Documents/Snapchat/Snapchat/Snapchat/ElegirUsuarioViewController.swift
//  Created by Juan Manuel Pino Cáceres on 16/05/18.
//  Copyright © 2018 tecsup. All rights reserved.
//

import UIKit
import Firebase

class ElegirUsuarioViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var usuarios:[Usuario] = []
    var imagenURL = ""
    var descrip = ""
    var imagenID = ""
    var audioID = ""
    var audioURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        Database.database().reference().child("usuarios").observe(DataEventType.childAdded, with: {(snapshot) in
            print(snapshot)
            
            let usuario = Usuario()
            usuario.email = (snapshot.value as! NSDictionary)["email"] as! String
            usuario.uid = snapshot.key
            self.usuarios.append(usuario)
            self.tableView.reloadData()
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usuarios.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let usuario = usuarios[indexPath.row]
        cell.textLabel?.text = usuario.email
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let usuario = usuarios[indexPath.row]
        let snap = ["from": Auth.auth().currentUser?.email, "description": descrip, "imagenURL": imagenURL, "imagenID": imagenID, "audioURL": audioURL, "audioID": audioID]
        
        Database.database().reference().child("usuarios").child(usuario.uid).child("snaps").childByAutoId().setValue(snap)
        navigationController?.popViewController(animated: true)
    }
}
