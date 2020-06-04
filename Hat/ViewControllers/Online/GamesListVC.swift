import UIKit

class GamesListVC: UIViewController {

    var gamesList: [Game.ListElement]!
    var gameLoaded: Game?
    var gameID: UUID?
    var gamesListTVC: GamesListTVC!
    var timer: Timer?
    var gameCode: String?
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var joinButton: MyButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addTaps(singleTapAction: #selector(singleTap), delegate: self)
        textField.becomeFirstResponder()
        textField.layer.borderColor = K.Colors.foreground.cgColor
        textField.layer.borderWidth = 1.0
        textField.autocorrectionType = .no
        joinButton.disable()
        textField.resignFirstResponder()
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        textField.keyboardType = .decimalPad
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        title = "Загружаем..."
        createTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancelTimer()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toGamesList" {
            gamesListTVC = segue.destination as? GamesListTVC
            loadGamesList(to: gamesListTVC)
            gamesListTVC.delegate = self
        } else if segue.identifier == "joinGame" {
            let newGameVC = segue.destination as! NewGameVC
            newGameVC.game = gameLoaded
            newGameVC.mode = (gameLoaded?.userOwnerID == Auth().id && gameLoaded?.turn == -1) ? .onlineCreateAfter : .onlineJoin
        }
    }
}

//MARK:- Private functions
extension GamesListVC {
    @objc private func textFieldDidChange(_ textField: UITextField) {
        gameCode = textField.text
        guard let gameCode = gameCode else {
            joinButton.disable()
            return
        }
        checkHackMode()
        
        joinButton.enable(if: gameCode.count >= K.Server.gameCodeCount)
    
    }
    @objc private func singleTap(recognizer: UITapGestureRecognizer) {
        if (recognizer.state == UIGestureRecognizer.State.ended) {
            if textField.isFirstResponder {
                textField.resignFirstResponder()
            } else {
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func pressJoinButton(_ sender: Any) {
        let code = textField.text!
        let joinData = JoinData(code: code)
        GameRequest.join(joinData: joinData) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let game):
                    self?.gameLoaded = game
                    self?.title = ""
                    self?.performSegue(withIdentifier: "joinGame", sender: self)
                case .failure(let error):
                    self?.showWarning(error)
                }
          }
        }
    }
    
    func loadGamesList(to gamesListTVC: GamesListTVC) {
        GameRequest.searchMine() { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let gamesList):
                    self?.gamesList = gamesList
                    gamesListTVC.gamesList = self!.gamesList
                    self?.title = "Введите код игры"
                    gamesListTVC.tableView.reloadData()
                case .failure(let error):
                    self?.showWarning(error)
                }
            }
        }
    }

    func loadGame(gameID: UUID) {
        showWarning("Загружаем игру...")
        GameRequest.accept(by: gameID) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let game):
                    self?.gameLoaded = game
                    self?.title = ""
                    self?.performSegue(withIdentifier: "joinGame", sender: self)
                case .failure(let error):
                    self?.showWarning(error)
                }
            }
        }
    }
    func checkHackMode() {
        if textField.text?.suffix(3) == ",,," {
            textField.keyboardType = .default
        }
    }
}

// MARK: - GameListDelegate
protocol GameListDelegate {
    func confirmJoin(gameNumber: Int)
    func showWarning(_ error: RequestError)
}
extension GamesListVC: GameListDelegate {
    func confirmJoin(gameNumber: Int) {
        let alert = UIAlertController(title: "Присоединиться к игре от  \(gamesList[gameNumber].userOwnerName)?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { action in
            guard gameNumber < self.gamesList.count else { return }
            self.gameID = UUID(uuidString: self.gamesList[gameNumber].id)
            guard self.gameID != nil else {
                self.showWarning(.other)
                return
            }
            self.loadGame(gameID: self.gameID!)
        }))
        alert.addAction(UIAlertAction(title: "Нет", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Timer
extension GamesListVC {
    @objc func updateTimer() {
        if let gamesListTVC = gamesListTVC {
            loadGamesList(to: gamesListTVC)
        }
    }
    
    func createTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: K.Server.settings.updateGameList, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            timer?.tolerance = 0.1
            //timer?.fire()
        }
    }
    
    func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - UIGestureRecognizerDelegate
extension GamesListVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return (touch.view == self.view) ? true : false
    }
}
