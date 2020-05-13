import Foundation

protocol NewGameVCDelegate: class {
    func add(toGame player: Player) -> Bool
    func goToInvitePlayerVC()
    func disableButton()
}

extension NewGameVC: NewGameVCDelegate {
    func add(toGame player: Player) -> Bool {
        if playersList.players.contains(player) {
            return false
        } else {
            playersTVC.insertRow(player: player, at: playersList.players.count)
            if playersList.players.count == K.minPlayersQty {
                button.enable()
            }
            return true
        }
    }
    
    func goToInvitePlayerVC() {
        performSegue(withIdentifier: "toInvitePlayer", sender: self)
    }
    func disableButton() {
        button.disable()
    }
}
