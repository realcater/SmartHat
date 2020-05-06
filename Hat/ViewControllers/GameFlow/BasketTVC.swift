//
//  BasketTVC.swift
//  Hat
//
//  Created by Dmitry Dementyev on 27.12.2019.
//  Copyright © 2019 Dmitry Dementyev. All rights reserved.
//

import UIKit

class BasketTVC: UITableViewController {
    
    var game: Game!
    
    @objc func buttonSelected(sender: UIButton){
        let row = Int(sender.accessibilityIdentifier!)!
        game.changeStatusInBasket(for: row)
        sender.setTitle(K.statusWordImages[game.basketStatus[row]], for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return game.basketWords.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordsListItem", for: indexPath)
        
        let textField = cell.viewWithTag(1000) as! UITextField
        textField.text = game.basketWords[indexPath.row]
        
        let button = cell.viewWithTag(1001) as! UIButton
        button.setTitle(K.statusWordImages[game.basketStatus[indexPath.row]], for: .normal)
        button.accessibilityIdentifier = String(indexPath.row)
        button.addTarget(self, action: #selector(buttonSelected), for: .touchUpInside)
        
        return cell
    }
}
