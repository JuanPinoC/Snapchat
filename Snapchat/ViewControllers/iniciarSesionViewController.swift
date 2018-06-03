//
//  iniciarSesionViewController.swift
//  Snapchat
//
//  Created by Juan Manuel Pino Cáceres on 14/05/18.
//  Copyright © 2018 tecsup. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class iniciarSesionViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func iniciarSesionTapped(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) {
            (user, error) in print("Intentando Iniciar Sesion")
            if error != nil{
                self.mostrarAlerta(title: "Error", message: "El usuario o contraseña son incorrectos, o la cuenta no existe", action: "Cancelar")
            }else{
                print("Inicio de Sesion Exitoso")
                self.performSegue(withIdentifier: "iniciarsesionsegue", sender: nil)
            }
        }
    }
    
    func mostrarAlerta(title: String, message: String, action: String){
        let alertaGuia = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelok = UIAlertAction(title: action, style: .default, handler: nil)
        alertaGuia.addAction(cancelok)
        present(alertaGuia, animated: true, completion: nil)
    }
}

