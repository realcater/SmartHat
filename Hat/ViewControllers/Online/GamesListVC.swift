import UIKit

class GamesListVC: UIViewController {

    var gamesList: [Game.Public] = []
    var gameLoaded: GameData?
    var gameID: UUID?
    var gamesListTVC: GamesListTVC!
    var timer: Timer?
    
    @IBOutlet weak var chooseGameButton: MyButton!
    
    @IBAction func chooseGameButtonPressed(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chooseGameButton.turnClickSoundOn(sound: K.Sounds.click)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        title = "Загружаем..."
        createLoadGameListTimer()
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
            newGameVC.gameData = gameLoaded
            newGameVC.mode = gameLoaded!.everyPlayerReady ? .onlineReady : .onlineWait
            newGameVC.gameID = gameID
        }
    }
}

//MARK:- Private functions
private extension GamesListVC {
    func loadGamesList(to gamesListTVC: GamesListTVC) {
        GameRequest.searchMine() { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let gamesList):
                    self?.gamesList = gamesList
                    gamesListTVC.gamesList = self!.gamesList
                    self?.title = (gamesListTVC.gamesList.count > 0) ? "Доступные игры" : "Нет доступных игр"
                    gamesListTVC.tableView.reloadData()
                case .failure(let error):
                    self?.showWarning(K.Server.warnings[error]!)
                }
            }
        }
    }
    func showWarning(_ text: String) {
        self.title = text
    }

    func loadGame(gameID: UUID) {
        showWarning("Загружаем игру...")
        GameRequest.search(by: gameID, setAccepted: true) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let game):
                    self?.gameLoaded = game
                    self?.performSegue(withIdentifier: "joinGame", sender: self)
                case .failure(let error):
                    self?.showWarning(K.Server.warnings[error]!)
                }
            }
        }
    }
}

// MARK: - GameListDelegate
protocol GameListDelegate {
    func confirmJoin(gameNumber: Int)
}
extension GamesListVC: GameListDelegate {
    func confirmJoin(gameNumber: Int) {
        let alert = UIAlertController(title: "Присоединиться к игре от  \(gamesList[gameNumber].userOwnerName)?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { action in
            self.gameID = UUID(uuidString: self.gamesList[gameNumber].gameID)
            guard self.gameID != nil else {
                self.showWarning(K.Server.warnings[.other]!)
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
    
    func createLoadGameListTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: K.Server.Time.updateGameList, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            timer?.tolerance = 0.1
            timer?.fire()
        }
    }
    
    func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
}
