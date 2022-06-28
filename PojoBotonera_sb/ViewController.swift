//
//  ViewController.swift
//  PojoBotonera_sb
//
//  Created by Alan Milke on 24/06/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var txtHost: UITextField!
    @IBOutlet weak var txtPort: UITextField!
    @IBOutlet weak var txtConsola: UITextView!
    
    @IBOutlet weak var btnConectar: UIButton!
    @IBOutlet weak var btnIzq: UIButton!
    @IBOutlet weak var btnDer: UIButton!
    
    private var conectado: Bool = false

    var chatRoom: ChatRoom?
    var botonera: Botonera?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtHost.text = "192.168.1.151"
        txtPort.text = "5656"
    }
    
    
    @IBAction func btnConectar_Pressed(_ sender: Any) {
        
        self.botonera = Botonera()
        /*chatRoom = ChatRoom()
        chatRoom?.setupNetworkCommunication(host: txtHost.text!, port: UInt32(txtPort.text!)!)
        chatRoom?.delegate = self*/
    }
    
    @IBAction func btnIzq_Pressed(_ sender: Any) {
        //chatRoom?.send(message: "!voz:Hola Coca Cola.")
        botonera?.sendMessage(message: "!voz Holi!")

        
        
    }
    
    @IBAction func btnDer_Pressed(_ sender: Any) {
        botonera?.sendMessage(message: "\n")
    }
    
    private func appendToTextField(string: String) {
      print(string)
      txtConsola.text = ("\(string)\n") + txtConsola.text
    }
}

extension ViewController: ChatRoomDelegate {
    func received(message: Message) {
        appendToTextField(string: message.message)
    }
}
