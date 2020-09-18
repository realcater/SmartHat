import Foundation

enum Mode {
    case offline
    case onlineCreateBefore
    case onlineCreateAfter
    case onlineJoin
}

extension NewGameVC {
    var mode: Mode {
        get {
            return _mode
        }
        set {
            _mode = newValue
            if let game = game, game.turn == K.endTurnNumber {
                title = "Игра завершена"
                button?.enable()
                button?.setTitle("Смотреть результаты", for: .normal)
                return
            }
            title = K.Titles.newGame[mode]
            button?.setTitle(K.Buttons.newGameVCTitle[mode], for: .normal)
            
            switch _mode {
            case .onlineJoin:
                button?.disable()
                tableIsVisible = true
                if isViewLoaded { replaceBackButton() }
                if let title = self.title, let code = game.code {
                    self.title = title + code
                }
            case .onlineCreateAfter:
                update = Update(game: game, showWarningOrTitle: showWarningOrTitle)
                tableIsVisible = true
                setAcceptedStatuses()
                playersTVC?.playersList = playersList
                playersTVC?.mode = _mode
                playersTVC?.tableView.reloadData()
                createStatusTimer()
                onlineInfoIsVisible = true
                button?.disable()
                picker?.isUserInteractionEnabled = false
                if isViewLoaded { replaceBackButton() }
                if let title = self.title, let code = game.code {
                    self.title = title + code
                }
            case .onlineCreateBefore:
                tableIsVisible = false
            default:
                button?.enable()
                tableIsVisible = true
            }
        }
    }
    
    func setAcceptedStatuses() {
        let myID = Auth().id
        playersList.players.forEach { $0.accepted = ($0.id == myID) }
    }
    
}
