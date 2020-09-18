//
//  GameListTVC.swift
//  Hat
//
//  Created by Realcater on 28.04.2020.
//  Copyright © 2020 Dmitry Dementyev. All rights reserved.
//

import UIKit

class GamesListTVC: UITableViewController {

    var gamesList: [Game.ListElement] = []
    var delegate: GameListDelegate?
    
    var noGames: Bool {
        return gamesList.count == 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isEditing = true
        tableView.allowsSelectionDuringEditing = true
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noGames ? gamesList.count+2 : gamesList.count+1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GamesList", for: indexPath)
        let gameOwnerNameTextField = cell.viewWithTag(1001) as! UITextField
        let createdAtTextField = cell.viewWithTag(1002) as! UITextField
        let turnTextField = cell.viewWithTag(1003) as! UITextField
        
        
        if indexPath.row == 0 {
            gameOwnerNameTextField.text = "Автор"
            createdAtTextField.text = "Создана"
            turnTextField.text = "Ход"
            cell.viewWithTag(1000)?.backgroundColor = K.Colors.foreground
            gameOwnerNameTextField.textColor = K.Colors.background
            gameOwnerNameTextField.font = UIFont.systemFont(ofSize: 20, weight: .medium)
            createdAtTextField.textColor = K.Colors.background
            turnTextField.textColor = K.Colors.background
            cell.selectionStyle = .none
        } else {
            cell.viewWithTag(1000)?.backgroundColor = UIColor.clear
            gameOwnerNameTextField.textColor = K.Colors.foreground
            gameOwnerNameTextField.font = UIFont.systemFont(ofSize: 20, weight: .regular)
            createdAtTextField.textColor = K.Colors.foreground
            turnTextField.textColor = K.Colors.foreground
            let contentView = cell.viewWithTag(1000)
            
            if indexPath.row == 1 && noGames {
                contentView?.getConstraint(named: "trailingCons")?.priority = .defaultLow
                cell.selectionStyle = .none
                gameOwnerNameTextField.text = "Нет игр с вашим участием"
                gameOwnerNameTextField.textAlignment = .center
                createdAtTextField.text = ""
                turnTextField.text = ""
            } else {
                //contentView?.getConstraint(named: "trailingCons")?.priority = .defaultHigh
                cell.selectionStyle = .default
                gameOwnerNameTextField.textAlignment = .left
                let stringCreatedAt = gamesList[indexPath.row-1].createdAt
                createdAtTextField.text = stringCreatedAt.convertFromZ()?.convertTo(use: "HH:mm")
                gameOwnerNameTextField.text = gamesList[indexPath.row-1].userOwnerName
                turnTextField.text = toString(turn: gamesList[indexPath.row-1].turn)
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return gameIsMine(indexPath) ? .delete : .none
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return gameIsMine(indexPath)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            if let gameID = getGameID(indexPath) {
                tryDelete(for: gameID) {
                    self.gamesList.remove(at: indexPath.row-1)
                    if self.gamesList.count > 0 {
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    } else {
                        tableView.reloadData()
                    }
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 0 && !noGames {
            tableView.deselectRow(at: indexPath, animated: true)
            delegate?.confirmJoin(gameNumber: indexPath.row-1)
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
}

extension GamesListTVC {
    func gameIsMine(_ index: IndexPath) -> Bool {
        if index.row == 0 || noGames { return false }
        return gamesList[index.row-1].userOwnerName == Auth().name
    }
    
    func getGameID(_ index: IndexPath) -> UUID? {
        if index.row == 0 || noGames { return nil }
        return UUID(uuidString: gamesList[index.row-1].id)
    }
    
    func tryDelete(for gameID: UUID, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: "Вы точно хотите удалить игру?", message: "Данная операция не обратима", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Да", style: .destructive, handler: { action in
            self.deleteGame(for: gameID) { completion() }
        }))
        alert.addAction(UIAlertAction(title: "Нет", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func deleteGame(for gameID: UUID, completion: @escaping () -> Void) {
        GameRequest.delete(gameID: gameID) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success:
                    completion()
                case .failure(let error):
                    self?.delegate?.showWarning(error)
                }
            }
        }
    }
}

extension GamesListTVC {
    func toString(turn: Int) -> String {
        switch turn {
        case K.endTurnNumber: return "🏆"
        case -1: return ""
        default: return String(turn+1)
        }
    }
}


