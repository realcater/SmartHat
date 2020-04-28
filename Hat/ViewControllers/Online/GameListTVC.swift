//
//  GameListTVC.swift
//  Hat
//
//  Created by Realcater on 28.04.2020.
//  Copyright © 2020 Dmitry Dementyev. All rights reserved.
//

import UIKit

class GameListTVC: UITableViewController {

    var games: [Game] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isEditing = false
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count+1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GamesListItem", for: indexPath)
        let gameOwnerTextField = cell.viewWithTag(1001) as! UITextField
        let playersCountTextField = cell.viewWithTag(1002) as! UITextField
        
        if indexPath.row == 0 {
            gameOwnerTextField.text = "Создатель"
            playersCountTextField.text = "#"
            cell.viewWithTag(1000)?.backgroundColor = K.Colors.foreground
        } else {
            gameOwnerTextField.text = games[indexPath.row+1].userOwner.name
            playersCountTextField.text = String(games[indexPath.row+1].gameData.players.count)
        }
        return cell
    }
}
