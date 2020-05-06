//
//  GameListTVC.swift
//  Hat
//
//  Created by Realcater on 28.04.2020.
//  Copyright © 2020 Dmitry Dementyev. All rights reserved.
//

import UIKit

class GamesListTVC: UITableViewController {

    var gamesList: [GameDBItem.Public] = []
    var delegate: GameListDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gamesList.count+1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GamesList", for: indexPath)
        let gameOwnerNameTextField = cell.viewWithTag(1001) as! UITextField
        let createdAtTextField = cell.viewWithTag(1002) as! UITextField
        
        if indexPath.row == 0 {
            gameOwnerNameTextField.text = "Автор"
            createdAtTextField.text = "Создана"
            cell.viewWithTag(1000)?.backgroundColor = K.Colors.foreground
            gameOwnerNameTextField.textColor = K.Colors.background
            createdAtTextField.textColor = K.Colors.background
        } else {
            gameOwnerNameTextField.text = gamesList[indexPath.row-1].userOwnerName
            let stringCreatedAt = gamesList[indexPath.row-1].createdAt
            createdAtTextField.text = Helper.getStringTime(from: stringCreatedAt)
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            delegate?.confirmJoin(gameNumber: indexPath.row-1)
        }
    }
}
