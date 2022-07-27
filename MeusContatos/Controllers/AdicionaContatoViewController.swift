//
//  AdicionaContatoViewController.swift
//  MeusContatos
//
//  Created by Natan Rodrigues on 25/07/22.
//

import UIKit
import CoreData

class AdicionaContatoViewController: UIViewController {
    
    @IBOutlet weak var tituloLabel: UILabel!
    @IBOutlet weak var nomeTextField: UITextField!
    @IBOutlet weak var numeroTextField: UITextField!
    
    var textoTitulo = "Adicionar Contato"
    var contato: NSManagedObject? = nil
    var indexPathContato: IndexPath? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tituloLabel.text = textoTitulo
        if let contato = self.contato {
            nomeTextField.text = contato.value(forKey: "nome") as? String
            numeroTextField.text = contato.value(forKey: "numero") as? String
        }
    }
    
    @IBAction func salvarFechar(_ sender: Any) {
        performSegue(withIdentifier: "verificaContatoLista", sender: self)
    }
    
    @IBAction func fechar(_ sender: Any) {
        nomeTextField.text = nil
        numeroTextField.text = nil
        performSegue(withIdentifier: "verificaContatoLista", sender: self)
    }
    
}
