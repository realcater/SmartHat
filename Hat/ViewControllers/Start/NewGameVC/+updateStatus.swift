
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
                }
            }
        }
    }
    
    func update(from playersStatus: [PlayerStatus]) {
        var anythingChanged = false
        for playerStatus in playersStatus {
            let player = playersList.players.first { $0.id == playerStatus.playerID }
            if let player = player, player.accepted != playerStatus.accepted {
                player.accepted = playerStatus.accepted
                anythingChanged = true
            }
        }
        if anythingChanged {
            playersTVC?.playersList = playersList
            playersTVC?.tableView.reloadData()
            mode = everyPlayerReady ? .onlineReady : .onlineWait
        }
    }
    
    var everyPlayerReady: Bool {
        return !playersList.players.map{$0.accepted}.contains(false)
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
