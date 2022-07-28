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

    // MARK: - Dados TableView

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return categorias.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoriaCell", for: indexPath)
        
        cell.textLabel?.text = categorias[indexPath.row].nome
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //Excluir a categoria
        let acaoDeletar = UIContextualAction(style: .destructive, title: "Excluir") { action, view, boolAction in
            let categoria = self.categorias[indexPath.row]
            
            self.deletar(categoria, at: indexPath)
            
            tableView.performBatchUpdates {
                tableView.deleteRows(at: [indexPath], with: .fade)
            } completion: { completed in
                tableView.reloadData()
            }
        }
        
        //Editar a categoria
        let acaoEditar = UIContextualAction(style: .normal, title: nil) { action, view, boolAction in
            var textField = UITextField()
            
            let alert = UIAlertController(title: "Editar categoria", message: "", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Concluir", style: .default) { (action) in
                
                
                let nomeEditado = textField.text!
                
                self.editarCategoria(indexPath: indexPath, nome: nomeEditado)
                tableView.reloadData()
                
            }
            
            alert.addAction(action)
            
            alert.addTextField { (field) in
                textField = field
                textField.placeholder = "Editar categoria"
            }
            
            self.present(alert, animated: true, completion: nil)
            
        }
        acaoEditar.image = UIImage(systemName: "pencil")
        
        return UISwipeActionsConfiguration(actions: [acaoDeletar, acaoEditar])
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
    
    func editarCategoria(indexPath: IndexPath, nome: String) {
        let categoria = categorias[indexPath.row]
        categoria.setValue(nome, forKey: "nome")
        
        do {
            try context.save()
            categorias[indexPath.row] = categoria
        } catch {
            print("Erro ao editar \(error)")
        }
    }
    
    func deletar(_ categoria: Categoria, at indexPath: IndexPath) {
        context.delete(categoria)
        categorias.remove(at: indexPath.row)
    }
    
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
