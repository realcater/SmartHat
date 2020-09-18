import Foundation
import UIKit

extension MainVC {
    func tryQuitGame(title: String = "Выйти из игры?", message: String = "Вы сможете продолжить позднее") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Да", style: .destructive, handler: {
            action in self.moveToStartVC()
        }))
        alert.addAction(UIAlertAction(title: "Пока нет", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func tryEndGame(title: String = "Закончить игру?", message: String = "Считаем очки и определяем победителя") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Давно пора", style: .destructive, handler: {
            action in self.showResults()
        }))
        alert.addAction(UIAlertAction(title: "Ещё поиграем", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func tryEndOrQuitGame(title: String = "Что делаем?", message: String = "Вы можете закончить игру или просто выйти, чтобы продолжить позднее") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Считаем очки", style: .destructive, handler: {
            action in self.showResults()
        }))
        alert.addAction(UIAlertAction(title: "Просто выйдем", style: .default, handler: {
            action in self.moveToStartVC()
        }))
        alert.addAction(UIAlertAction(title: "Ещё поиграем", style: .default, handler: nil))
        
        if turnTimer != nil { alert.actions[0].isEnabled = false }
        present(alert, animated: true, completion: nil)
    }
    
    func moveToStartVC() {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
