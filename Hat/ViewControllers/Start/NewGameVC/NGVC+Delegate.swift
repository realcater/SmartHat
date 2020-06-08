import Foundation

protocol NewGameVCDelegate: class {
    func add(toGame player: Player, successCompletion: @escaping ()->Void, failedCompletion: @escaping ()->Void)
    func add(toLocalData player: Player)
    func goToInvitePlayerVC(isOnlinePlayerToInvite: Bool)
    func disableButton()
    func updatePlayersList(players: [Player])
}

extension NewGameVC: NewGameVCDelegate {
    func add(toGame player: Player, successCompletion: @escaping ()->Void,  failedCompletion: @escaping ()->Void) {
        if playersList.players.contains(player) {
            failedCompletion()
        } else {
            if mode == .onlineCreateAfter {
                GameRequest.add(to: game.id, player: player) { [weak self] result in
                    DispatchQueue.main.async { [weak self] in
                        switch result {
                        case .success:
                            self!.add(toLocalData: player)
                            successCompletion()
                        case .failure(let error):
                            self?.showWarning(error)
                        }
                    }
                }
            } else {
                if mode == .onlineCreateBefore, playersList.players.count == K.minPlayersQty {
                    button.enable()
                }
                playersTVC.insertRow(player: player, at: playersList.players.count)
                successCompletion()
            }
        }
    }
    func add(toLocalData player: Player) {
        game.data.players.append(player)
        playersTVC.insertRow(player: player, at: playersList.players.count)
    }
    
    func goToInvitePlayerVC(isOnlinePlayerToInvite: Bool) {
        self.isOnlinePlayerToInvite = isOnlinePlayerToInvite
        performSegue(withIdentifier: "toInvitePlayer", sender: self)
    }
    func disableButton() {
        button.disable()
    }
    func updatePlayersList(players: [Player]) {
        game.data.players = players
        update.setFull()
    }
}
