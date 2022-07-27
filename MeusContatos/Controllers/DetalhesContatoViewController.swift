//
//  DetalhesContatoViewController.swift
//  MeusContatos
//
//  Created by Natan Rodrigues on 25/07/22.
//

import UIKit
import CoreData

class DetalhesContatoViewController: UIViewController {

    @IBOutlet weak var nomeLabel: UILabel!
    @IBOutlet weak var numeroLabel: UILabel!
    
    var contato = Contato()
    var deletado: Bool = false
    var indexPath: IndexPath? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nomeLabel.text = contato.value(forKey: "nome") as? String
        numeroLabel.text = contato.value(forKey: "numero") as? String
    }
    
    @IBAction func voltar(_ sender: Any) {
        performSegue(withIdentifier: "verificaContatoLista", sender: self)
    }
    
    @IBAction func deletarContato(_ sender: Any) {
        deletado = true
        performSegue(withIdentifier: "verificaContatoLista", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editarContatoSegue" {
            guard let viewController = segue.destination as? AdicionaContatoViewController else { return }
            viewController.textoTitulo = "Editar Contato"
            viewController.contato = contato
            viewController.indexPathContato = self.indexPath
        }
    }
}
