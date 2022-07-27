//
//  CategoriaTableViewController.swift
//  MeusContatos
//
//  Created by Natan Rodrigues on 25/07/22.
//

import UIKit
import CoreData

class CategoriaTableViewController: UITableViewController {

    var categorias = [Categoria]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        carregaCategorias()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return categorias.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoriaCell", for: indexPath)
        
        cell.textLabel?.text = categorias[indexPath.row].nome
        
        return cell
    }
    
    //MARK: - Métodos delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "vaiParaContatosSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinoVC = segue.destination as! ContatosTableViewController
        
        //pegar a categoria que corresponde a celula selecionada
        //identificará a linha atual que esta selecionada
        if let indexPath = tableView.indexPathForSelectedRow {
            destinoVC.selecionaCategoria = categorias[indexPath.row]
        }
    }
    
    //MARK: - Manipula os dados
    
    func salvarCategorias() {
        do {
            try context.save()
        } catch {
            print("Erro ao salvar categoria \(error)")
        }
        
        tableView.reloadData()
    }
    
    func carregaCategorias() {
        let request: NSFetchRequest<Categoria> = Categoria.fetchRequest()
        
        do {
            categorias = try context.fetch(request)
        } catch {
            print("Erro ao carregar categorias \(error)")
        }
        
        tableView.reloadData()
    }

    
    @IBAction func adicionaCategoria(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Adicionar nova categoria", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Adicionar", style: .default) { (action) in
            
            let novaCategoria = Categoria(context: self.context)
            novaCategoria.nome = textField.text!
            
            self.categorias.append(novaCategoria)
            
            self.salvarCategorias()
            
        }
        
        alert.addAction(action)
        
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Adicionar nova categoria"
        }
        
        present(alert, animated: true, completion: nil)
    }
    
}
