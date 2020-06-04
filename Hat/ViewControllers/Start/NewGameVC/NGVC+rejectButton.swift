import Foundation
import UIKit

extension NewGameVC {
    func replaceBackButton() {
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(self.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    func showAlert() {
        let alert = UIAlertController(title: "Выйти из игры?", message: "Вы сможете присоединиться к игре позднее", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { action in
            self.rejectGame()
            self.navigationController?.popToRootViewController(animated: true)
            //self.performSegue(withIdentifier: "toGameType", sender: self)
        }))
        alert.addAction(UIAlertAction(title: "Нет", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    func rejectGame() {
        GameRequest.reject(gameID: self.game.id) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success:
                    self?.cancelStatusTimer()
                case .failure(let error):
                    self?.showWarning(error)
                }
            }
        }
    }
}
