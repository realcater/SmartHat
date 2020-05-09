//
//  BasketTVC.swift
//  Hat
//
//  Created by Dmitry Dementyev on 27.12.2019.
//  Copyright © 2019 Dmitry Dementyev. All rights reserved.
//

import UIKit

class BasketTVC: UITableViewController {
    
    var gameData: GameData!
    
    @objc func buttonSelected(sender: UIButton){
        let row = Int(sender.accessibilityIdentifier!)!
        gameData.changeStatusInBasket(for: row)
        sender.setTitle(K.statusWordImages[gameData.basketStatus[row]], for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameData.basketWords.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordsListItem", for: indexPath)
        
        let textField = cell.viewWithTag(1000) as! UITextField
        textField.text = gameData.basketWords[indexPath.row]
        
        let button = cell.viewWithTag(1001) as! UIButton
        button.setTitle(K.statusWordImages[gameData.basketStatus[indexPath.row]], for: .normal)
        button.accessibilityIdentifier = String(indexPath.row)
        button.addTarget(self, action: #selector(buttonSelected), for: .touchUpInside)
        
        return cell
    }
}
