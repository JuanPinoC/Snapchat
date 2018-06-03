//
//  CrearUsuarioViewController.swift
//  Snapchat
//
//  Created by Juan Manuel Pino Cáceres on 23/05/18.
//  Copyright © 2018 tecsup. All rights reserved.
//

import UIKit
import Firebase

class CrearUsuarioViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func btnCrearTapped(_ sender: Any) {
        Auth.auth().createUser(withEmail: self.emailTextField.text!,
            password: self.passwordTextField.text!, completion: {(user,error) in
                print("Intentando crear un usuario")
                if error != nil{
                    print("Se presento el siguiente error al crear el usuario:\(String(describing: error))")
                }else{
                    print("El usuario fue creado exitosamente")
                    Database.database().reference().child("usuarios").child(user!.user.uid).child("email").setValue(user!.user.email)
                    self.mostrarAlerta(title: "Creaciòn exitosa", message: "La cuenta ha sido creada", action: "Ok")
                }
        })
    }
    
    func mostrarAlerta(title: String, message: String, action: String){
        let alertaGuia = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelok = UIAlertAction(title: action, style: .default, handler: nil)
        alertaGuia.addAction(cancelok)
        present(alertaGuia, animated: true, completion: nil)
    }
    
    @IBAction func btnAtrasTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
