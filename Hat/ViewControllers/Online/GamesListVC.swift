import UIKit

class GamesListVC: UIViewController {

    var gamesList: [Game.Public] = []
    var gameLoaded: GameData?
    
    @IBOutlet weak var chooseGameButton: MyButton!
    
    @IBAction func chooseGameButtonPressed(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chooseGameButton.turnClickSoundOn(sound: K.Sounds.click)
        title = "Загружаем..."
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toGamesList" {
            let gamesListTVC = segue.destination as! GamesListTVC
            loadGamesList(to: gamesListTVC)
            gamesListTVC.delegate = self
        } else if segue.identifier == "joinGame" {
            let newGameVC = segue.destination as! NewGameVC
            newGameVC.mode = .onlineJoin
            newGameVC.gameData = gameLoaded
        }
    }
}

extension GamesListVC {
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
        GameRequest.search(by: gameID) { [weak self] result in
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
protocol GameListDelegate {
    func confirmJoin(gameNumber: Int)
}
extension GamesListVC: GameListDelegate {
    func confirmJoin(gameNumber: Int) {
        let alert = UIAlertController(title: "Присоединиться к игре от  \(gamesList[gameNumber].userOwnerName)?", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { action in
                guard let gameID = UUID(uuidString: self.gamesList[gameNumber].gameID) else {
                    self.showWarning(K.Server.warnings[.other]!)
                    return
                }
                self.loadGame(gameID: gameID)
            }))
            alert.addAction(UIAlertAction(title: "Нет", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
    }
}
