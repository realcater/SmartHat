//
//  ResultsTVC.swift
//  Hat
//
//  Created by Dmitry Dementyev on 27.12.2019.
//  Copyright © 2019 Dmitry Dementyev. All rights reserved.
//

import UIKit



class EndGameTVC: UITableViewController {

    var players: [Player]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isEditing = false
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count+1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultsListItem", for: indexPath)
        let nameTextField = cell.viewWithTag(1001) as! UITextField
        let ttlTextField = cell.viewWithTag(1002) as! UITextField
        let tellTextField = cell.viewWithTag(1003) as! UITextField
        let listenTextField = cell.viewWithTag(1004) as! UITextField
        
        if indexPath.row == 0 {
            
            nameTextField.text = ""
            ttlTextField.text = ""
            tellTextField.text = ""
            listenTextField.text = ""
            
            ttlTextField.background = UIImage(named: "sum-white-256")
            tellTextField.background = UIImage(named: "bubble-white-256")
            listenTextField.background = UIImage(named: "ear-white-256")
            
            cell.viewWithTag(1005)?.backgroundColor = K.Colors.foreground
        } else {
            nameTextField.text = players[indexPath.row-1].name
            ttlTextField.text = String(players[indexPath.row-1].ttlGuesses)
            tellTextField.text = String(players[indexPath.row-1].tellGuessed)
            listenTextField.text = String(players[indexPath.row-1].listenGuessed)
        }
        return cell
    }
    

}
