//
//  PeopleTableViewController.swift
//  Chat
//
//  Created by  mac on 2/2/20.
//  Copyright © 2020 Vladimir. All rights reserved.
//

import UIKit

class PeopleTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var users: [User] = []
    
    // Передаем nil, чтобы отображать результат поиска в этом же ViewController'е
    var searchController = UISearchController(searchResultsController: nil)
    
    var searchResults: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBarController()
        setupNavigationBar()
        setupTableView()
        observeUsers()
    }
    
    func setupTableView(){
        //
        tableView.tableFooterView = UIView()
    }
    
    func setupSearchBarController(){
        // Присваиваем self, чтобы вызывать встроенные методы из UISearchResultsUpdating
        searchController.searchResultsUpdater = self
        
        // Затемняет экран при поиске
        //searchController.dimsBackgroundDuringPresentation = true
        
        //Можно листать при работающем поиске страницу
        searchController.obscuresBackgroundDuringPresentation = false
        // Что будет написано по дефолту в searchBar'e
        searchController.searchBar.placeholder = "Search for users..."
        // Какого цвета будет searchBar
        searchController.searchBar.barTintColor = UIColor.white
        
        //
        searchController.definesPresentationContext = true
        
        // Прячем searchBar при скроллинге страницы
        
        
        navigationItem.searchController = searchController
    }
    
    // Настраиваем NavigationBar
    func setupNavigationBar(){
        navigationItem.title = "People"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let location = UIBarButtonItem(image: UIImage(systemName: "mappin.and.ellipse"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(locationPressed))
        navigationItem.leftBarButtonItem = location
        
    }
    
    @objc func locationPressed(){
        
        let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
        let usersArounVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_USERS_AROUND) as! UsersAroundViewController
        
        self.navigationController?.pushViewController(usersArounVC, animated: true)
    }
    
    // Добавляет юзеров в ячейки контроллера
    func observeUsers(){
        // При успехе вызывается часть {}, это onSuccess из Api.User.observeUsers
        Api.User.observeUsers { (user) in
            
            //В массив юзеров добавляем каждого юзера
            self.users.append(user)
            
            // Перезаружаем информацию в ячейках
            self.tableView.reloadData()
        }
    }

    // Возвращает список набор подходящих под наш поиск юзеров
    func filterContent(for searchText: String){
        searchResults = self.users.filter{
            // Применяет функцию-предикат и возвращает другой массив, состоящий исключительно из тех юзеров первоначального массива users, для которых входная функция-предикат возвращает true.
            return $0.username.lowercased().range(of: searchText) != nil
        }
    }
    
    //MARK: - UISearchResultsUpdating
    
    // Вызывается когда юзер делает изменения в searchBar'e
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text == nil || searchController.searchBar.text!.isEmpty{
            self.view.endEditing(true)
        }
        else {
            // преобразуем написанный текст в нижний регистр
            let textLowercaser = searchController.searchBar.text!.lowercased()
            
            filterContent(for: textLowercaser)
        }
        tableView.reloadData()
    }
    
    // Вызывается, когда выбираем определенную строку
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? UsersTableViewCell{

            let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
            let chatVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_CHAT) as! ChatViewController
            chatVC.imagePartner = cell.avatar.image
            chatVC.partnerUsername = cell.usernameLabel.text
            chatVC.partnerId = cell.user.uid
            // Перебрасываем пользователя на ChatViewController
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
        
    }
    

    
    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if searchController.isActive{
            return searchResults.count
        }
        else{
            return self.users.count
        }
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: IDENTIFIER_CELL_USERS , for: indexPath) as! UsersTableViewCell
        
        // Configure the cell...
        
        let user = searchController.isActive ? searchResults[indexPath.row] : users[indexPath.row]
        
        cell.controller = self
        
        cell.loadData(user)

        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
