//
//  ImagenViewController.swift
//  Snapchat
//
//  Created by Juan Manuel Pino Cáceres on 16/05/18.
//  Copyright © 2018 tecsup. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class ImagenViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate{

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var elegirContactoBoton: UIButton!
    
    @IBOutlet weak var btnGrabar: UIButton!
    @IBOutlet weak var btnReproducir: UIButton!
    
    @IBOutlet weak var lblDuracion: UILabel!
    
    var imagePicker = UIImagePickerController()
    var imagenID = NSUUID().uuidString
    
    var audioRecorder:AVAudioRecorder?
    var audioPlayer:AVAudioPlayer?
    
    var audioID = NSUUID().uuidString
    var audioURL = ""
    var audioURLreproductor:URL?
    
    var seconds = 0
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecorder()
        btnReproducir.isEnabled = false
        imagePicker.delegate = self
        elegirContactoBoton.isEnabled = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [String : Any]){
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.image = image
        imageView.backgroundColor = UIColor.clear
        elegirContactoBoton.isEnabled = true
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func audioTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "agregarAudio", sender: nil)
    }
    
    @IBAction func mediaTapped(_ sender: Any) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cameraTapped(_ sender: Any) {
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func elegirContactoTapped(_ sender: Any) {
        elegirContactoBoton.isEnabled = false
        agregarAudio()
        let imagenesFolder = Storage.storage().reference().child("imagenes")
        let imagenData = UIImageJPEGRepresentation(imageView.image!, 0.1)!
        let imagen = imagenesFolder.child("\(imagenID).jpg")
        imagen.putData(imagenData, metadata: nil){(metadata, error) in
            if error != nil{
                self.mostrarAlerta(title: "Error", message: "Se produjo un error al subir la imagen. Vuelva a intentarlo.", action: "Cancelar")
                self.elegirContactoBoton.isEnabled = true
                print("Ocurrio un error al subir imagen: \(String(describing: error))")
                return
            }else{
                imagen.downloadURL(completion: { (url, error) in
                    guard url != nil else{
                        self.mostrarAlerta(title: "Error", message: "Se produjo un error al obtener información de imagen.", action: "Cancelar")
                        self.elegirContactoBoton.isEnabled = true
                        print("Ocurrio un error al obtener la informacion de imagen \(String(describing: error))")
                        return
                    }
                    self.performSegue(withIdentifier: "seleccionarContactoSegue", sender: url?.absoluteString)
                })
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != "agregarAudio"{
            let siguienteVC = segue.destination as! ElegirUsuarioViewController
            siguienteVC.imagenURL = sender as! String
            siguienteVC.descrip = descriptionTextField.text!
            siguienteVC.imagenID = imagenID
            siguienteVC.audioID = audioID
            siguienteVC.audioURL = audioURL
        }
    }
    
    func mostrarAlerta(title: String, message: String, action: String){
        let alertaGuia = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelok = UIAlertAction(title: action, style: .default, handler: nil)
        alertaGuia.addAction(cancelok)
        present(alertaGuia, animated: true, completion: nil)
    }
    
    func runTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,
                                     selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer(){
        seconds += 1
        lblDuracion.text = "" + String(seconds)
    }
    
    @IBAction func grabarTapped(_ sender: Any) {
        if audioRecorder!.isRecording{
            audioRecorder?.stop()
            btnGrabar.setTitle("Grabar", for: .normal)
            btnReproducir.isEnabled = true
            seconds = 0
            timer.invalidate()
        } else {
            audioRecorder?.record()
            btnGrabar.setTitle("Detener", for: .normal)
            btnReproducir.isEnabled = false
            runTimer()
        }
    }

    @IBAction func reproducirTapped(_ sender: Any) {
        do{
            try audioPlayer = AVAudioPlayer(contentsOf: audioURLreproductor!)
            audioPlayer!.play()
        } catch{}
    }
    
    func agregarAudio() {
        let audiosFolder = Storage.storage().reference().child("audios")
        let audioData = NSData(contentsOf: audioURLreproductor!)
        let audio = audiosFolder.child("\(audioID).m4a")
        audio.putData(audioData! as Data, metadata: nil){
            (metadata, error) in
            if error != nil{
                self.mostrarAlerta(title: "Error", message: "Se produjo un error al subir el audio. Vuelva a intentarlo.", action: "Cancelar")
                print("Ocurrio un error al subir audio: \(String(describing: error))")
                return
            }else{
                audio.downloadURL(completion: { (url, error) in
                    guard let enlaceURL = url else{
                        self.mostrarAlerta(title: "Error", message: "Se produjo un error al obtener información de audio.", action: "Cancelar")
                        print("Ocurrio un error al obtener la informacion de audio \(String(describing: error))")
                        return
                    }
                    self.audioURL = (url?.absoluteString)!
                })
            }
        }
    }
    
    func setupRecorder(){
        do{
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath, "audio.m4a"]
            audioURLreproductor = NSURL.fileURL(withPathComponents: pathComponents)
            
            print("**********************************")
            print(audioURLreproductor)
            print("**********************************")
            
            var settings:[String:AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            audioRecorder = try AVAudioRecorder(url: audioURLreproductor!, settings: settings)
            audioRecorder!.prepareToRecord()
            
        } catch let error as NSError {
            print(error)
        }
    }
    
}
