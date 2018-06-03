//
//  VerSnapViewController.swift
//  Snapchat
//
//  Created by Juan Manuel Pino Cáceres on 24/05/18.
//  Copyright © 2018 tecsup. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import AVFoundation

class VerSnapViewController: UIViewController {

    @IBOutlet weak var btnReproducir: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
   
    var snap = Snap()
    var audioPlayer:AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text? = snap.descrip
        imageView.sd_setImage(with: URL(string: snap.imagenURL))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Database.database().reference().child("usuarios").child((Auth.auth().currentUser?.uid)!).child("snaps").child(snap.id).removeValue()
        
        Storage.storage().reference().child("imagenes").child("\(snap.imagenID).jpg").delete{
            (error) in
            print("Se elimino la imagen correctamente")
        }
        
        Storage.storage().reference().child("audios").child("\(snap.audioID).jpg").delete{
            (error) in
            print("Se elimino el audio correctamente")
        }
    }
    
    @IBAction func reproducirTapped(_ sender: Any) {
        do{
            try audioPlayer = AVAudioPlayer(contentsOf: URL(string: snap.audioURL)!)
            audioPlayer!.play()
        } catch{
            print("error al reproducir el archivo de audio")
        }
    }
    
}
