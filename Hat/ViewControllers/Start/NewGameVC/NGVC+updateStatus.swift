
import Foundation

extension NewGameVC {
    func requestUpdatePlayerStatus() {
        GameRequest.getPlayersStatus(gameID: self.gameID!) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let playersStatus):
                    self?.update(from: playersStatus)
                case .failure(let error):
                    self?.showWarning(K.Server.warnings[error]!)
                    if error == .noConnection { self?.makeMeNotInGame() }
                }
            }
        }
    }
    
    func update(from playersStatus: [PlayerStatus]) {
        var anythingChanged = false
        for playerStatus in playersStatus {
            let player = playersList.players.first { $0.id == playerStatus.playerID }
            if let player = player {
                if player.accepted != playerStatus.accepted {
                    player.accepted = playerStatus.accepted
                    anythingChanged = true
                }
                if player.inGame != playerStatus.inGame {
                    player.inGame = playerStatus.inGame
                    anythingChanged = true
                }
            }
        }
        if anythingChanged {
            playersTVC?.playersList = playersList
            playersTVC?.tableView.reloadData()
            mode = everyPlayerReady ? .onlineReady : .onlineWait
        }
    }
    
    var everyPlayerReady: Bool {
        return !playersList.players.map{ $0.accepted && $0.inGame }.contains(false)
    }
    func makeMeNotInGame() {
        let myID = Auth().id
        if let player = playersList.players.first(where: { $0.id == myID }) {
            player.inGame = false
        }
        playersTVC.tableView.reloadData()
    }
}

// MARK: - Timer
extension NewGameVC {
    @objc func updateTimer() {
        requestUpdatePlayerStatus()
    }
    
    func createUpdateStatusTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: K.Server.Time.updatePlayersStatus, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            timer?.tolerance = 0.1
            timer?.fire()
        }
    }
    
    func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
}
