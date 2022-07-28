//
//  ContatosTableViewController.swift
//  MeusContatos
//
//  Created by Natan Rodrigues on 25/07/22.
//

import UIKit
import CoreData

class ContatosTableViewController: UITableViewController {
    
    var contatosArray = [Contato]()
    
    var selecionaCategoria: Categoria? {
        didSet{
            carregaContatos()
        }
    }
    
    //acessa a classes UIApplication obtendo o objeto que corresponde ao aplicativo atual
    //agora tem acesso ao AppDelegate como objeto para obter viewContext do persistentContainer
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Dados TableView
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contatosArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContatoCell", for: indexPath)
        
        let contato = contatosArray[indexPath.row]
        
        cell.textLabel?.text = contato.nome
        cell.detailTextLabel?.text = contato.numero
        
        return cell
    }
    
    //MARK: - Manipula dados
    
    //Salvar
    func salvarContatos(nome: String, numero: String) {
        guard let entity = NSEntityDescription.entity(forEntityName:"Contato", in: context) else { return }
        let contato = Contato(entity: entity, insertInto: context)
        
        contato.setValue(nome, forKey: "nome")
        contato.setValue(numero, forKey: "numero")
        contato.recebeCategoria = self.selecionaCategoria
        
        do {
            try context.save()
            self.contatosArray.append(contato)
        } catch {
            print("Erro ao salvar context \(error)")
        }
        self.tableView.reloadData()
    }
    
    //Editar
    func editarContato(indexPath: IndexPath, nome: String, numero: String) {
        let contato = contatosArray[indexPath.row]
        contato.setValue(nome, forKey: "nome")
        contato.setValue(numero, forKey: "numero")
        
        do {
            try context.save()
            contatosArray[indexPath.row] = contato
        } catch {
            print("Erro ao editar \(error)")
        }
    }
    
    //Deletar
    func deletar(_ contato: Contato, at indexPath: IndexPath) {
        context.delete(contato)
        contatosArray.remove(at: indexPath.row)
    }
    
    //Carregar
    func carregaContatos(with request: NSFetchRequest<Contato> = Contato.fetchRequest(), predicate: NSPredicate? = nil) {
        let categoriaPredicate = NSPredicate(format: "recebeCategoria.nome MATCHES %@", selecionaCategoria!.nome!)
        request.sortDescriptors = [NSSortDescriptor(key: "nome", ascending: true)]
        
        if let adicionaPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoriaPredicate, adicionaPredicate])
        } else {
            request.predicate = categoriaPredicate
        }
        
        
        do {
            contatosArray = try context.fetch(request)
        } catch {
            print("Erro ao carregar dados do context \(error)")
        }
        
        tableView.reloadData()
    }
    
    //verifica para executar as funções
    @IBAction func verificaContatoLista(segue: UIStoryboardSegue) {
        if let viewController = segue.source as? AdicionaContatoViewController {
            guard let nome: String = viewController.nomeTextField.text, let numero: String = viewController.numeroTextField.text else { return }
            if nome != "" && numero != "" {
                if let indexPath = viewController.indexPathContato {
                    editarContato(indexPath: indexPath, nome: nome, numero: numero)
                } else {
                    salvarContatos(nome: nome, numero: numero)
                }
            }
            tableView.reloadData()
        } else if let viewController = segue.source as? DetalhesContatoViewController {
            if viewController.deletado {
                guard let indexPath: IndexPath = viewController.indexPath else { return }
                let contato = contatosArray[indexPath.row]
                deletar(contato, at: indexPath)
                tableView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detalheContatoSegue" {
            guard let NViewController = segue.destination as? UINavigationController else { return }
            guard let viewController = NViewController.topViewController as? DetalhesContatoViewController else { return }
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let contato = contatosArray[indexPath.row]
            viewController.contato = contato
            viewController.indexPath = indexPath
        }
    }
    
}

//MARK: - Métodos da SearchBar
//separa e estende a capacidade do controlador para lidar com métodos de pesquisa
extension ContatosTableViewController: UISearchBarDelegate {
    //função de pesquisa
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //vai buscar objetos em forma de Item - necessário especificar o tipo de dado que vai buscar
        let request : NSFetchRequest<Contato> = Contato.fetchRequest()
        //NSPredicate é básicamente uma classe que especifica os dados que devem ser buscados
        //[cd] faz distinção entre letra minuscula e maiscula
        let predicate = NSPredicate(format: "nome CONTAINS[cd] %@", searchBar.text!)
        
        //organiza a pesquisa em ordem alfabética
        request.sortDescriptors = [NSSortDescriptor(key: "nome", ascending: true)]
        
        carregaContatos(with: request, predicate: predicate)
        
    }
    //função que identifica as letras que tem na barra de pesquisa e volta todos os itens da lista
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            carregaContatos() //carrega todos os itens existentes na lista salva no core data
            
            //executando na fila principal
            DispatchQueue.main.async { //gerencia a prioridade das threads //atualiza a interface do usuario
                searchBar.resignFirstResponder() //volta para o estado original
            }
            
        }
    }
}
