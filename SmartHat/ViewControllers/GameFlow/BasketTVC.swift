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
    var editable: Bool!
    weak var delegate: BasketVCDelegate?
    
    @objc func buttonSelected(sender: UIButton){
        guard editable else {
            delegate?.showWarning()
            return
        }
        let row = Int(sender.accessibilityIdentifier!)!
        game.changeStatusInBasket(for: row)
        sender.setTitle(K.statusWordImages[game.data.basketStatus[row]], for: .normal)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 0.5)
        let line = UIView(frame: frame)
        self.tableView.tableHeaderView = line
        line.backgroundColor = self.tableView.separatorColor
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return game.data.basketWords.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordsListItem", for: indexPath)
        
        let textField = cell.viewWithTag(1000) as! UITextField
        textField.text = game.basketWordToShow(for: indexPath.row) // game.data.basketWords[indexPath.row]
        
        let button = cell.viewWithTag(1001) as! UIButton
        button.setTitle(K.statusWordImages[game.data.basketStatus[indexPath.row]], for: .normal)
        button.accessibilityIdentifier = String(indexPath.row)
        button.addTarget(self, action: #selector(buttonSelected), for: .touchUpInside)
        
        return cell
    }
}
