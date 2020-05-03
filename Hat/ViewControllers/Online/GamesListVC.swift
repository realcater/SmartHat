import UIKit

class GamesListVC: UIViewController {

    var gamesList: [Game.Public] = []
    
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
            loadGames(to: gamesListTVC)
            gamesListTVC.delegate = self
        } else if segue.identifier == "joinGame" {
            let newGameVC = segue.destination as! NewGameVC
            newGameVC.mode = .onlineJoin
        }
    }
}

extension GamesListVC {
    func loadGames(to gamesListTVC: GamesListTVC) {
        GameRequest.searchMine() { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                    case .success(let gamesList):
                        self?.gamesList = gamesList
                        gamesListTVC.gamesList = self!.gamesList
                        self?.title = "Доступные игры"
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
}
protocol GameListDelegate {
    func confirmJoin(gameNumber: Int)
}
extension GamesListVC: GameListDelegate {
    func confirmJoin(gameNumber: Int) {
        let alert = UIAlertController(title: "Присоединиться к игре от  \(gamesList[gameNumber].userOwnerName)?", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Да", style: .default, handler: {
                action in self.performSegue(withIdentifier: "joinGame", sender: self)
            }))
            alert.addAction(UIAlertAction(title: "Нет", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
    }
}
